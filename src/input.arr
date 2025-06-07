#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder-pawtograder.

  pyret-autograder-pawtograder is free software: you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  pyret-autograder-pawtograder is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder-pawtograder. If not, see <http://www.gnu.org/licenses/>.
|#

import json as J
import string-dict as SD
import pathlib as Path
import file("../node_modules/pyret-autograder/src/main.arr") as A

provide:
  process-spec
end

# none of the validation in this file is intended to be particuluarly helpful,
# the zod schema in lib/schema.js should be used to validate the data with nicer
# messages

fun expect-obj(json :: J.JSON) -> SD.StringDict<J.JSON>:
  cases (J.JSON) json:
  | j-obj(sd) => sd
  | else => raise("Expected an object")
  end
end

fun expect-arr(json :: J.JSON) -> List<J.JSON>:
  cases (J.JSON) json:
  | j-arr(l) => l
  | else => raise("Expected an array")
  end
end

fun expect-str(json :: J.JSON) -> String:
  cases (J.JSON) json:
  | j-str(s) => s
  | else => raise("Expected a string")
  end
end

fun expect-num(json :: J.JSON) -> Number:
  cases (J.JSON) json:
  | j-num(n) => n
  | else => raise("Expected a number")
  end
end


fun convert-runner(
  solution-dir :: String,
  submission-dir :: String,
  entry :: String,
  grader :: SD.StringDict<J.JSON>
) -> (-> A.GradingIncome):
  typ = grader.get-value("type") ^ expect-str

  ask:
    | typ == "well-formed" then:
      # TODO: maybe pyret-autograder should expose this thunk
      lam():
        A.check-well-formed(entry)
      end
    | (typ == "wheat") or (typ == "chaff") then:
      config = grader.get-value("config") ^ expect-obj
      _path = config.get-value("path") ^ expect-str
      path = Path.resolve(Path.join(solution-dir, _path))
      func = config.get-value("function") ^ expect-str
      if typ == "wheat":
        A.chaff(entry, path, func)
      else:
        A.wheat(entry, path, func)
      end
    | typ == "functional" then:
      config = grader.get-value("config") ^ expect-obj
      _path = config.get-value("path") ^ expect-str
      path = Path.resolve(Path.join(solution-dir, _path))
      check-name = config.get-value("check") ^ expect-str
      A.functional(entry, path, check-name)
    | typ == "validator" then:
      config = grader.get-value("config") ^ expect-obj
      func = config.get-value("function") ^ expect-str
      A.validator(entry, func)
    | otherwise: raise("unkown grader type " + typ)
  end
end

fun convert-grader(
  solution-dir :: String,
  submission-dir :: String,
  default-entry :: Option<String>,
  id :: String,
  grader :: SD.StringDict<J.JSON>
) -> A.Grader block:
  deps = grader.get("deps")
               .and-then(expect-arr)
               .or-else([list:])
               .map(expect-str)

  entry-opt = grader.get("entry")
                    .and-then(expect-str)
                    .or-else(default-entry)

  # invariant not enforced by schema:
  when (is-none(entry-opt)):
    raise(
      "Grader " + id +
      " does not specify an `entry`point and no `default_entry` provided"
    )
  end

  entry = Path.resolve(Path.join(submission-dir, entry-opt.value))

  runner = convert-runner(solution-dir, submission-dir, entry, grader)

  # FIXME: this needs to be updates when more thought it put into artifacts
  metadata = grader.get("points")
                   .and-then(expect-num)
                   .and-then(A.visible(_))
                   .or-else(A.invisible)

  A.node(id, deps, runner, metadata)
end

fun process-spec(spec :: J.JSON) -> A.Graders:
  doc: ```
       Processes a grading spec which should follow satisfy the Spec type found
       in ../lib/types.d.ts
       ```
  toplevel = expect-obj(spec)

  solution-dir = toplevel.get-value("solution_dir") ^ expect-str
  submission-dir = toplevel.get-value("submission_dir") ^ expect-str
  config = toplevel.get-value("config") ^ expect-obj

  default-entry = config.get("default_entry").and-then(expect-str) # optional
  graders = config.get-value("graders") ^ expect-obj

  for map(id from graders.keys-list()):
    grader = graders.get-value(id) ^ expect-obj
    convert-grader(solution-dir, submission-dir, default-entry, id, grader)
  end
end

