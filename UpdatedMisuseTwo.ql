import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

/** Define a getBytes() methodaccess class */
class GetBytes extends MethodAccess{
  GetBytes(){
    this.getMethod().getName() = "getBytes"
  }
}
/** Define a IvParameterSpec constructor class */
class IvParameterSpec extends Constructor{
  IvParameterSpec(){
    this.getDeclaringType().hasQualifiedName("javax.crypto.spec", "IvParameterSpec")
  }
}

from GetBytes method, AssignExpr assign, Expr source, IvParameterSpec ivParameterSpec, Call sink
where assign.getDest() = source // Gets the destination (left-hand side) of the assignment.
and method.getQualifier().toString() = source.toString() // Make sure that the variable calling getBytes() method equals to source.
and source.getType() instanceof TypeString // Make sure that the source is a string.
and sink.getCallee() = ivParameterSpec // Get the sink constructor.
//and TaintTracking::localTaint(DataFlow::exprNode(source), DataFlow::exprNode(method.getQualifier()))
and TaintTracking::localTaint(DataFlow::exprNode(method), DataFlow::exprNode(sink.getArgument(0))) // Make sure that data flows from getBytes() method to the constructor.
select source, method, sink, "Initial Vector for CBC mode should not be a constant string!"