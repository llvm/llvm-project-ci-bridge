add_llvm_component_library(LLVMVEAsmParser
  VEAsmParser.cpp

  LINK_COMPONENTS
  MC
  MCParser
  Support
  VEDesc
  VEInfo

  ADD_TO_COMPONENT
  VE
  )
