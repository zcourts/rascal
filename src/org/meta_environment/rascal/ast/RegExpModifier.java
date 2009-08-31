package org.meta_environment.rascal.ast; 
import org.eclipse.imp.pdb.facts.INode; 
public abstract class RegExpModifier extends AbstractAST { 
static public class Lexical extends RegExpModifier {
	private String string;
         public Lexical(INode node, String string) {
		this.node = node;
		this.string = string;
	}
	public String getString() {
		return string;
	}

 	public <T> T accept(IASTVisitor<T> v) {
     		return v.visitRegExpModifierLexical(this);
  	}
}
static public class Ambiguity extends RegExpModifier {
  private final java.util.List<org.meta_environment.rascal.ast.RegExpModifier> alternatives;
  public Ambiguity(INode node, java.util.List<org.meta_environment.rascal.ast.RegExpModifier> alternatives) {
	this.alternatives = java.util.Collections.unmodifiableList(alternatives);
         this.node = node;
  }
  public java.util.List<org.meta_environment.rascal.ast.RegExpModifier> getAlternatives() {
	return alternatives;
  }
  
  public <T> T accept(IASTVisitor<T> v) {
     return v.visitRegExpModifierAmbiguity(this);
  }
}
}