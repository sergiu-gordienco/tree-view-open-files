{requirePackages} = require 'atom-utils'
{CompositeDisposable} = require 'event-kit'
_ = require 'lodash'

TreeViewOpenFilesPaneView = require './tree-view-open-files-pane-view'

module.exports =
class TreeViewOpenFilesView
	constructor: (serializeState) ->
		# Create root element
		@element = document.createElement('div')
		@element.classList.add('tree-view-open-files')
		@groups = []
		@paneSub = new CompositeDisposable
		@paneSub.add atom.workspace.observePanes (pane) =>
			@addTabGroup pane
			destroySub = pane.onDidDestroy =>
				destroySub.dispose()
				@removeTabGroup pane
			@paneSub.add destroySub

	addTabGroup: (pane) ->
		group = new TreeViewOpenFilesPaneView
		group.setPane pane
		@groups.push group
		@element.appendChild group.element

	removeTabGroup: (pane) ->
		group = _.findIndex @groups, (group) -> group.pane is pane
		@groups[group].destroy()
		@groups.splice group, 1

	# Returns an object that can be retrieved when package is activated
	serialize: ->

	# Tear down any state and detach
	destroy: ->
		@element.remove()
		@paneSub.dispose()

	# Toggle the visibility of this view
	toggle: ->
		if @element.parentElement?
			@element.remove()
		else
			requirePackages('tree-view').then ([treeView]) =>
				treeView.treeView.prepend @element