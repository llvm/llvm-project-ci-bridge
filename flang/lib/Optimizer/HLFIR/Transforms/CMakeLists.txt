get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)

add_flang_library(HLFIRTransforms
  BufferizeHLFIR.cpp
  ConvertToFIR.cpp
  LowerHLFIRIntrinsics.cpp
  SimplifyHLFIRIntrinsics.cpp

  DEPENDS
  FIRDialect
  HLFIROpsIncGen
  ${dialect_libs}

  LINK_LIBS
  FIRDialect
  FIRBuilder
  FIRDialectSupport
  FIRSupport
  HLFIRDialect
  MLIRIR
  ${dialect_libs}

  LINK_COMPONENTS
  AsmParser
  AsmPrinter
  Remarks
)
