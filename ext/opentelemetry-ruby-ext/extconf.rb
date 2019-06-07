require 'mkmf'

dir_config('opentelemetry-ruby-ext')

have_library('stdc++') or raise "required to have a c++ standard library"

$srcs = Dir.glob("**/*.cc")
$VPATH << "$(srcdir)/opencensus/proto"
$INCFLAGS << " -I$(srcdir)/opencensus/proto/"
$CXXFLAGS += ' -std=c++11 -Wall -Wno-deprecated-register -Os'
$LIBS << ' -lstdc++'

create_makefile 'opentelemetry-ruby-ext'



