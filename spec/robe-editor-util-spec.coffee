RobeEditorUtil = require '../lib/robe-editor-util'

describe 'RobeEditorUtil', ->
  [buffer, editor] = []

  beforeEach ->
    waitsForPromise ->
      atom.project.open().then (value) -> editor = value

  describe '.currentContext', ->
    plain =
      '''
      class SomeClass
        def method
          current_context
        end
      end
      '''

    it 'returns method name and class name of specified position', ->
      editor.setText plain
      expect(RobeEditorUtil.currentContext(editor, [2, 10])) # curren*t_context
        .toEqual(moduleName: 'SomeClass', isInstanceMethod: true, methodName: 'method')

    it 'does not return methodName when cursor is overlapped with def statement', ->
      editor.setText plain
      expect(RobeEditorUtil.currentContext(editor, [1, 11])) # def metho*dA
        .toEqual(moduleName: 'SomeClass', isInstanceMethod: false, methodName: null)

    it 'does not return methodName when cursor is outside of end statement of def', ->
      editor.setText plain
      expect(RobeEditorUtil.currentContext(editor, [4, 0])) # *end
        .toEqual(moduleName: 'SomeClass', isInstanceMethod: false, methodName: null)

    it 'returns nested class name using "::"', ->
      editor.setText(
        '''
        module Foo::Bar
          class NestedClass
            before_validation :hoge
          end
        end
        '''
      )
      expect(RobeEditorUtil.currentContext(editor, [2, 0])) # *    before_validation
        .toEqual(moduleName: 'Foo::Bar::NestedClass', isInstanceMethod: false, methodName: null)

    it 'does not include sibling inner class in moduleName', ->
      editor.setText(
        '''
        class SomeClass
          class Inner
            def some_method
            end
          end

          def another_method
            current_context
          end
        end
        '''
      )
      expect(RobeEditorUtil.currentContext(editor, [7, 19])) # current_conte*xt
        .toEqual(moduleName: 'SomeClass', isInstanceMethod: true, methodName: 'another_method')

    it 'detects class method when cursor is in "self." prefixed method def', ->
      editor.setText(
        '''
        class SomeClass
          def self.class_method
          end
        end
        '''
      )
      expect(RobeEditorUtil.currentContext(editor, [2, 0])) # *  end
        .toEqual(moduleName: 'SomeClass', isInstanceMethod: false, methodName: 'class_method')

    it 'detects class method when cursor is in "Constant." prefixed method def', ->
      editor.setText(
        '''
        def OtherClass.another_class_method
        end
        '''
      )
      expect(RobeEditorUtil.currentContext(editor, [1, 0])) # *end
        .toEqual(moduleName: 'OtherClass', isInstanceMethod: false, methodName: 'another_class_method')

    it 'detects class method when using eigenclass by "class << self"', ->
      editor.setText(
        '''
        class OtherClass
          class << self
            def class_method
            end
          end
        end
        '''
      )
      expect(RobeEditorUtil.currentContext(editor, [3, 0])) # *    end (matching def class_methdo)
        .toEqual(moduleName: 'OtherClass', isInstanceMethod: false, methodName: 'class_method')
