import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otlet/business_logic/models/goal.dart';

const List<String> litGenres = [
  'Drama',
  'Fable',
  'Fairy Tale',
  'Fantasy',
  'Fiction',
  'Fiction in Verse',
  'Folklore',
  'Historical Fiction',
  'Horror',
  'Humor',
  'Legend',
  'Mystery',
  'Mythology',
  'Poetry',
  'Realistic Fiction',
  'Science Fiction',
  'Short Story',
  'Tall Tale',
  'Biography',
  'Autobiography',
  'Essay',
  'Narrative Nonfiction',
  'History',
  'Nonfiction',
  'Speech'
];

Color primaryColor = Color(0xFF14213D);
Color secondaryColor = Color(0xFFE5E5E5);
Color accentColor = Color(0xFFFCA311);

List<String> chartColorCodes = [
  '3366cc',
  'dc3912',
  'ff9900',
  '109618',
  '990099',
  '0099c6',
  'dd4477',
  '66aa00',
  'b82e2e',
  '316395',
  '994499',
  '22aa99',
  'aaaa11',
  '6633cc',
  'e67300',
  '8b0707',
  '651067',
  '329262',
  '5574a6',
  '3b3eac',
  'b77322',
  '16d620',
  'b91383',
  'f4359e',
  '9c5935',
  'a9c413',
  '2a778d',
  '668d1c',
  'bea413',
  '0c5922',
  '743411',
].map((e) => '#$e').toList();

DateFormat monthDayYearFormat = DateFormat('MMMM d, y');

Map<Unit, String> unitDisplays = Map.fromIterables(Unit.values,
    Unit.values.map((e) => e.toString().replaceAll('Unit.', '')).toList());

Image defaultAppBarTitle = Image.asset(
  'assets/images/book_logo_small.png',
  scale: 2.7,
);

Map<String, String> packageLicenses = Map.fromIterables(
    [
      'Async',
      'Shared Preferences',
      'Uuid',
      'Http',
      'Provider',
      'Cached Network Image',
      'Flutter Barcode Scanner',
      'Charts Flutter',
      'In App Purchase',
      'Flutter Launcher Icons',
      'Intl',
      'Flutter Native Splash'
    ],
    [
      'Copyright 2015, the Dart project authors.$bsdLicense',
      'Copyright 2017 The Chromium Authors. All rights reserved.$bsdLicense',
      'Copyright (c) 2021 Yulian Kuncheff$mitLicense',
      'Copyright 2014, the Dart project authors.$bsdLicense',
      'Copyright (c) 2019 Remi Rousselet$mitLicense',
      'Copyright (c) 2018 Rene Floor$mitLicense',
      'Copyright (c) 2019 Amol Gangadhare$mitLicense',
      'Copyright [yyyy] [name of copyright owner]$apacheLicense',
      'Copyright 2013 The Flutter Authors. All rights reserved.$bsdLicense',
      "Copyright (c) 2019 Mark O'Sullivan$mitLicense",
      'Copyright 2013, the Dart project authors. All rights reserved.$bsdLicense',
      "Copyright (c) 2019 Mark O'Sullivan$mitLicense",
    ].map((e) => e.contains(mitLicense) ? 'MIT License\n\n' + e : e));

String bsdLicense =
    '\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n* Neither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.';

String mitLicense =
    '\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';

String apacheLicense =
    '\n\nLicensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.';
