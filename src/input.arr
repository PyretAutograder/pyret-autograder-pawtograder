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
import file("../node_modules/pyret-autograder/src/main.arr") as A

fun expect-obj(json :: J.JSON, msg :: String) -> SD.StringDict<JSON>:
  cases (J.JSON) json:
  | j-obj(sd) => sd
  | else => raise("Expected an object " + msg)
  end
end

fun process-spec(spec :: J.JSON) -> A.Graders:
  doc: ```
       Processes a grading spec which should follow satisfy the Spec type found
       in ../lib/types.d.ts
       ```
  toplevel = expect-obj(spec)

end
