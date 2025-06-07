/*
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
*/

export type Spec = {
  solution_dir: string;
  submission_dir: string;
  config: Config;
};

export type Config = {
  grader: "pyret";
  default_entry?: string; // relative to submission_dir
  graders: Record<string, Grader>;
};

interface BaseGrader {
  deps?: string[];
  points?: number;
  /**
   * The path of the entry point to the student's program.
   *
   * Defaults to {@link Spec.config.default_entry}
   */
  entry?: string;
}

interface WellFormedGrader extends BaseGrader {
  type: "well-formed";
}

interface ExamplarGrader extends BaseGrader {
  type: "wheat" | "chaff";
  config: {
    path: string;
    /** the name of the function to use */
    function: string;
  };
}

interface FuntionalityGrader extends BaseGrader {
  type: "functional";
  config: {
    path: string;
    /** the name of the check block to use in the provided path */
    check: string;
  };
}

// TODO: this needs a better name
interface ValidatorGrader extends BaseGrader {
  type: "validator";
  config: {
    function: string;
  };
}

export type Grader =
  | WellFormedGrader
  | ExamplarGrader
  | FuntionalityGrader
  | ValidatorGrader;
