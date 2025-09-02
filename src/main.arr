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
include file("input.arr")
include file("output.arr")
import npm("pyret-autograder", "main.arr") as A
import npm("pyret-autograder", "utils.arr") as U
import sets as S
import json as J

provide:
  grade-pawtograder-spec
end

fun validate-dag<B, R, E, I, C>(
  dag :: List<A.Node<B, R, E, I, C>>
) -> Nothing block:
  doc: ```
    Determines if a list of nodes form a valid directed acyclic graph (DAG)
    meaning that:
    - they don't form cycles
    - each node has a unique id
  ```
  ids = dag.map(_.id)

  when U.has-duplicates(ids):
    raise("dag has duplicate id")
  end

  for each(x from dag) block:
    when not(x.deps.all(ids.member(_))):
      raise("not all deps exist for " + x.id)
    end
    nothing
  end

  dict = U.list-to-stringdict(dag.map(lam(n): {n.id; n.deps} end))

  fun has-cycle-from(id :: A.Id, path-set :: S.Set<A.Id>):
    dict.get-value(id).any(lam(dep):
      path-set.member(dep) or
      has-cycle-from(dep, path-set.add(dep))
    end)
  end

  for each(id from ids) block:
    when has-cycle-from(id, [S.list-set: id]):
      raise("cycle from " + id)
    end
  end

  nothing
end


fun grade-pawtograder-spec(spec :: String) -> J.JSON block:
  # this can throw, but that's fine since we don't need to respond gracefully
  # if provided an invalid spec (should be validated using the provided schema)
  spec-json = J.read-json(spec)

  graders = process-spec(spec-json)
  validate-dag(graders)

  result = A.grade(graders)

  output = prepare-for-pawtograder(result)

  output
end
