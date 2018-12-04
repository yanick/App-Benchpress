requires "DateTime::Functions" => "0";
requires "Dumbbench" => "0";
requires "Dumbbench::Instance::PerlSub" => "0";
requires "Hash::Merge" => "0";
requires "JSON" => "0";
requires "List::AllUtils" => "0";
requires "Module::Pluggable" => "0";
requires "Module::Runtime" => "0";
requires "Moose" => "0";
requires "Moose::Exporter" => "0";
requires "MooseX::App::Simple" => "0";
requires "experimental" => "0";
requires "perl" => "v5.20.0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::More" => "0";
  requires "strict" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Test::More" => "0.96";
  requires "Test::Vars" => "0";
};
