require 'ffi'
module Neven
  extend FFI::Library
  ffi_lib 'neven/libneven.so'
  class NevenFace < FFI::Struct
    layout :confidence, :float,
           :midpointx, :float,
           :midpointy, :float,
           :eyedist, :float
  end
  attach_function :neven_create, [ :int, :int, :int ], :pointer
  attach_function :neven_detect, [ :pointer, :pointer ], :int
  attach_function :neven_get_face, [ :pointer, :pointer, :int ], :int
  attach_function :neven_destroy, [ :pointer ], :void
end


