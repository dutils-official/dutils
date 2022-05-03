/*This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.*/
/** Copyright: 2022, Ruby The Roobster*/
/**Author: Ruby The Roobster, <rubytheroobster@yandex.com>*/
/**Date: January 19, 2021*/
/** License:  GPL-3.0**/
module dutils;

version(DLL)
{
	mixin("export:");
}

else
{
	mixin("public:");
}

import dutils.binom;
import dutils.physics;
import dutils.skeleton;
import dutils.transform;
import dutils.sprite;
import dutils.math;
