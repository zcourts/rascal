/*******************************************************************************
 * Copyright (c) 2009-2011 CWI
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:

 *   * Arnold Lankamp - Arnold.Lankamp@cwi.nl
*******************************************************************************/
package org.rascalmpl.parser.gtd.result.action;

import org.eclipse.imp.pdb.facts.IConstructor;

/**
 * This interface is intended to enable the execution of semantic actions on
 * arbitrary nodes in the parse forest; either to filter them and / or to
 * register information about them (or whatever else the user intents to do
 * with them).
 * <br /><br />
 * These actions are guaranteed to be executed from left to right, down-up.
 * <br /><br />
 * Environment creation will be left up to the user. Before entering each
 * production or node an event will be fired to enable the user to do this at
 * any given time. Backtracking will be taken care of by the flattener.
 * Although, upon exiting a production an event will be fired non-the-less.
 * This event will indicate whether the last handled production was completed
 * or filtered, so the user has the opportunity to do whatever bookkeeping is
 * necessary.
 * 
 * @author Arnold Lankamp
 */
public interface IActionExecutor{
	
	/**
	 * Called before invoking the flattener to enable the user to supply a root
	 * environment to the flattener.
	 * 
	 * @return The root environment.
	 */
	IEnvironment createRootEnvironment();
	
	/**
	 * Called after the completion of the flattener to enable the user to
	 * perform any required actions (cleanup for example).
	 * 
	 * @param environment The environment at the point of completion (the root
	 * environment).
	 * @param filtered True if the flattener failed to produce a valid tree,
	 * because of filtering; false otherwise.
	 */
	void completed(IEnvironment environment, boolean filtered);
	
	/**
	 * Called before entering each production. The callee can decide whether or
	 * not a new environment should be created. Additionally it provides the
	 * opportunity to handle other kinds of bookkeeping.
	 * 
	 * @param production The production we are entering.
	 * @param parent The parent environment.
	 * @return The environment the flattener should use for this production.
	 */
	IEnvironment enteringProduction(IConstructor production, IEnvironment parent);
	
	/**
	 * Called before entering each node in the given production. Hereby we
	 * supply users the opportinity to create a new environment before handling
	 * the indicated node.
	 * 
	 * @param production The production we are flattening for.
	 * @param index The position of the node in the production we are going to
	 * handle now.
	 * @param environment The parent environment.
	 * @return The environment the flattener should use for the indicated node.
	 */
	IEnvironment enteringNode(IConstructor production, int index, IEnvironment environment);
	
	/**
	 * Called after exiting a production; enabling the user to execute
	 * arbitrary bookkeeping actions.
	 * 
	 * @param production The production we are exiting.
	 * @param filtered True if the alternative for the given production got
	 * filtered; false otherwise.
	 * @param environment The environment at the point of exiting.
	 */
	void exitedProduction(IConstructor production, boolean filtered, IEnvironment environment);
	
	/**
	 * Supplies the user with the opportunity to filter alternatives and / or
	 * execute sematic actions.
	 * 
	 * @param tree The tree to handle.
	 * @param environment The environment associated with the given tree at the
	 * point at which the production was completed.
	 * @return The tree to replace the given tree with. May be null to indicate
	 * the tree should be removed from the forest.
	 */
	IConstructor filterProduction(IConstructor tree, IEnvironment environment);
	
	/**
	 * Supplies the user with the opportunity to filter and / or execute
	 * semantic actions for ambiguity clusters.
	 * 
	 * @param ambCluster The ambiguity cluser.
	 * @param environment The environment associated with the given ambiguity
	 * cluster at the point of its completion.
	 * @return The tree to replace the given ambiguity cluster with. May be
	 * null to indicate the cluster should be removed from the tree.
	 */
	IConstructor filterAmbiguity(IConstructor ambCluster, IEnvironment environment);
	
	/**
	 * Supplies the user with the opportunity to filter and / or execute
	 * semantic actions for cycle trees.
	 * 
	 * @param cycle The cycle tree.
	 * @param environment The environment associated with the given cycle tree
	 * at the point of its completion.
	 * @return The tree to replate the given cycle tree with. May be null to
	 * indicate the cycle should be removed from the forest.
	 */
	IConstructor filterCycle(IConstructor cycle, IEnvironment environment);
}
