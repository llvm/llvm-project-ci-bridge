add_mlir_dialect_library(MLIRIRDL
  IR/IRDL.cpp
  IRDLLoading.cpp

  DEPENDS
  MLIRIRDLIncGen
  MLIRIRDLOpsIncGen
  MLIRIRDLTypesIncGen

  LINK_LIBS PUBLIC
  MLIRDialect
  MLIRIR
  MLIRInferTypeOpInterface
  MLIRSideEffectInterfaces
  )
