module demo::Parsing::Parsing

import List;
import Set;
import IO;
import UnitTest;

/* Very preliminary LR parser generator */

public data Symbol      = t(str text) | nt(str name) | epsilon;

public alias Rule       = tuple[str name, list[Symbol] symbols];
public data Grammar     = grammar(str start, set[Rule] rules);  

// First and follow

public map[Symbol, set[Symbol]] FIRST = ();

public set[Symbol] firstNonEmpty(Grammar G, list[Symbol] symbols){
    println("firstNonEmpty(<symbols>)");
	for(Symbol sym <- symbols){
	    switch(sym){
	    case t(_):
	    	return {sym};
	    case nt(str name): {
	    		frts = first(G, subject);
	 			if(epsilon notin frts)
					return frts - {epsilon};
			}
		}
	}
	return {};
}

public set[Symbol] first(Grammar G, Symbol sym){
 	println("first(<sym>)");
	switch(sym){
	
	case epsilon: return {epsilon};
	
	case t(_): return {sym};
	
	case nt(str name): {
	        nonterm = subject;
	        
			for(list[Symbol] symbols <- G.rules[name]){
				f = firstNonEmpty(G, symbols);
				if(isEmpty(f))
					FIRST[nonterm] += epsilon;
				else
					FIRST[nonterm] += f;
			}
			return FIRST[nonterm];
		}
	}
	
}


// ------------ Items ------------------------------
data Item = item(str name, list[Symbol] left, list[Symbol] right);

public Item makeItem(Rule r){
	//println("makeItem(<r>)");
	return item(r.name, [], r.symbols);
}

private bool canMove(Item it, Symbol sym){
   return !isEmpty(it.right) && head(it.right) == sym;
}

private Item moveRight(Item it){
   return item(it.name, it.left + [head(it.right)], tail(it.right));
}

private Symbol getSymbol(Item it){
   return head(it.right);
}

private bool atEnd(Item it){
   return isEmpty(it.right);
}

private bool atNonTerminal(Item it){
	bool res = !isEmpty(it.right) && nt(_) := head(it.right);
	//println("atNonTerminal(<it>) => <res>");
	return res;
}

private str getNonTerminal(Item it){
	Symbol h = head(it.right);
	if(nt(str Name) := h)
		return Name;
}
	
private bool atTerminal(Item it){
	return !isEmpty(it.right) && t(_) := head(it.right);
}

private bool atSymbol(Item it, Symbol sym){
	return !isEmpty(it.right) && sym == head(it.right);
}

private bool isEmpty(Item it){
   return isEmpty(it.left) &&  isEmpty(it.right);
}


//-------- ItemSets ---------------------------------------

alias ItemSet = set[Item];

public ItemSet closure(Grammar G, ItemSet I){
	//println("closure(<G>, <I>)");
    with 
    	ItemSet items = I;
    solve {
        for(Item item <- items){
            if(atNonTerminal(item)){
        	   nonterm = getNonTerminal(item);
        	   for(list[Symbol] symbols <- G.rules[nonterm]){
        	       //println("symbols = <symbols>");
        		   items = items + makeItem(<nonterm, symbols>);
        	   }
            }
        }
    }
    return items;
}

public ItemSet goto(Grammar G, ItemSet I, Symbol sym){
	//println("goto(<G>, <I>, <sym>)");
    return closure(G, {moveRight(it) | Item it <- I, atSymbol(it, sym)});
}

public set[ItemSet] items(Grammar G){
	// Extract the symbols from the grammar
	set[Symbol] symbols = { sym | Rule r <- G.rules, Symbol sym <- r.symbols};
	// Add a new start rule
	Rule startRule = <"START", [nt(G.start)]>;
	G.rules = G.rules + {startRule};  // TODO += does not seem to work here

	with 
		set[ItemSet] C = {{ closure(G, {makeItem(startRule)}) }};  // TODO: {{ }} horror
	solve {
		C += { GT | ItemSet I <- C, Symbol X <- symbols, ItemSet GT := goto(G, I, X), !isEmpty(GT)};
	}
	return C;      
}

public Grammar G1 = grammar("E",
{
<"E", [nt("E"), t("*"), nt("B")]>,
<"E", [nt("E"), t("+"), nt("B")]>,
<"E", [nt("B")]>,
<"B", [t("0")]>,
<"B", [t("1")]>
});

public Grammar G2 = grammar( "E",
{
<"E",  [nt("T"), nt("E1")]>,
<"E1", [t("+"), nt("T"), nt("E1")]>,
<"E1", []>,
<"T",  [nt("F"), nt("T1")]>,
<"T1", [t("*"), nt("F"), nt("T1")]>,
<"T1", []>,
<"F",  [t("("), nt("E"), t(")")]>,
<"F",  [t("id")]>
});

public bool test(){

    assertEqual(first(G2, nt("E")), {t("("), t("id")});
    
	assertEqual(items(G1),
	{
	//0
	{item("B",[],[t("1")]),item("E",[],[nt("E"),t("*"),nt("B")]),item("E",[],[nt("E"),t("+"),nt("B")]), item("START",[],[nt("E")]),item("E",[],[nt("B")]),item("B",[],[t("0")])},
	//1
	{item("B",[t("0")],[])},
	//2
	{item("B",[t("1")],[])},
	//3
	{item("E",[nt("E")],[t("*"),nt("B")]),item("START",[nt("E")],[]),item("E",[nt("E")],[t("+"),nt("B")])},
	//4
	{item("E",[nt("B")],[])},
	//5
	{item("E",[nt("E"),t("*")],[nt("B")]),item("B",[],[t("1")]),item("B",[],[t("0")])},
	//6
	{item("B",[],[t("1")]),item("E",[nt("E"),t("+")],[nt("B")]),item("B",[],[t("0")])},
	//7
	{item("E",[nt("E"),t("*"),nt("B")],[])},
	//8
	{item("E",[nt("E"),t("+"),nt("B")],[])}
	});
	
	return report("Parser");
}

