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

import npm("pyret-autograder", "main.arr") as A
import slice-from-function from npm("pyret-autograder", "common/slicing.arr")
import parse-path from npm("pyret-autograder", "common/ast.arr")
import json as J
import string-dict as SD

include either

provide:
  data FeedbotInfo,
  mk-feedbot,
end

data FeedbotInfo:
  | feedbot-info(
      model :: String,
      prompt :: String,
      max-tokens :: Number,
      temperature :: Number
  ) with:
    method serialize(self) -> J.JSON:
      [SD.string-dict:
        "model", self.model,
        "prompt", self.prompt,
        "max_tokens", self.max-tokens,
        "temperature", self.temperature]
    end
end

fun score-feedbot(
  path :: String, fn-name :: String
  # model :: String, base-prompt :: String,
  # max-tokens :: Number, temperature :: Number
):
  cases (Either) parse-path(path):
    | left(err) =>
      left({
        to-string: lam():
          to-repr(err)
        end
      })
    | right(prog) =>
      sliced = slice-from-function(prog, fn-name)
      # TODO: populate
      info = feedbot-info("", "", 0, 0)
      right({0; info})
  end
end

fun fmt-feedbot(_, info :: FeedbotInfo) -> A.ComboAggregate:
  general = A.output-text("")
  staff = none
  {general; staff}
end


# TODO: determine inputs
fun mk-feedbot(
  id :: A.Id, deps :: List<A.Id>, path :: String, fn-name :: String,
  model :: String, base-prompt :: String, max-tokens :: Number,
  temperature :: Number
):
  name = "Feedbot for " + fn-name
  scorer = score-feedbot
  fmter = fmt-feedbot
  max-score = 0
  part = some(fn-name)
  A.mk-simple-scorer(id, deps, scorer, name, max-score, fmter, part)
end

