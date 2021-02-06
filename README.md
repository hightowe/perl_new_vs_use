# perl_new_vs_use
Searches a perl code file for "Foo->new()" where "use Foo" is missing in the file

## Usage Examples
~~~
$ perl_new_vs_use.pl ./MyModule.pm

$ find ./perl_src_dir -name \*.pm -o -name \*.pl | xargs -n 1 perl_new_vs_use.pl
~~~

~~~
$ cat ./Foo.pm 
#!/usr/bin/perl
use strict;
use Email::MIME;
use Email::MIME;
my $coder = JSON::XS->new();
my $coder = JSON::XS->new->foo->baz;


$ perl_new_vs_use.pl ./Foo.pm 
./Foo.pm
 * Email::MIME is used more than once: 2 times
 * JSON::XS->new( was seen but no corresponding "use JSON::XS"
 * JSON::XS->new->foo->baz; was seen but no corresponding "use JSON::XS"
~~~
