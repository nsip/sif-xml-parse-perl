# Project Name

SIF::XML::Parse - Generic SIF XML Object Parser

## Installation

Requires Perl 5, XML::Simple

## Usage

 use SIF::XML::Parse;
 my $data = SIF::XML::Parse->parse($xml);
 print $data->{type} . "\n";

## SIF US 3.0

Parses SIF US 3.0

* students

## SIF AU 1.3

Parses SIF AU 1.3

* StudentPersonal
* SchoolInfo
* StaffInfo
* RoomInfo
* StaffAssignment
* StaffPersonal
* TeachingGroup
* TimeTable
* TimeTableCell
* TimeTableSubject

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

* 2013-08-07 - Initial release basic US, larger AU set

## Credits

Scott Penrose <scottp@dd.com.au>

## License

Copyright 2013 National Schools Interoperability Program http://www.nsip.edu.au/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License 
is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied. 
See the License for the specific language governing permissions and limitations under the License.
