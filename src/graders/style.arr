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

import npm("pyret-autograder", "main.arr") as AG
import ast as A
import npm("pyret-autograder", "common/ast.arr") as CA
import json as J
import string-dict as SD

include either

provide:
  data StyleInfo,
  mk-style,
end

data StyleInfo:
  | parser-error(err :: CA.ParsePathError)
  | style-info with:
    method serialize(self):
      [SD.string-dict: ]
    end
end

fun check-fun-names(ast :: A.Program):
  nothing
end

fun score-style(
  path :: String 
):
  cases (Either) CA.parse-path(path):
    | left(err) =>
      right({0; parser-error(err)})
    | right(prog) =>
      info = style-info
      # TODO:
      right({0; info})
  end
end

fun fmt-style(_, info :: StyleInfo) -> AG.ComboAggregate:
  general = AG.output-text("Coming soon")
  staff = none
  {general; staff}
end

fun mk-style(
  id :: AG.Id, deps :: List<AG.Id>, path :: String, max-score :: Number
):
  name = "Automated Style Grading"
  scorer = lam():
    score-style(path)
  end
  fmter = fmt-style
  part = none 
  AG.mk-simple-scorer(id, deps, scorer, name, max-score, fmter, part)
end
