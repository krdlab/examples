import React, { PropTypes } from 'react'
import Todo from './Todo'
import { List } from 'react-toolbox/lib/list'

const TodoList = ({ todos, onTodoClick }) => (
  <List selectable ripple>
    {todos.map(todo =>
      <Todo
        key={todo.id}
        {...todo}
        onClick={() => onTodoClick(todo.id)}
      />
    )}
  </List>
)

TodoList.propTypes = {
  todos: PropTypes.arrayOf(
      PropTypes.shape({
        id: PropTypes.number.isRequired,
        completed: PropTypes.bool.isRequired,
        text: PropTypes.string.isRequired
      }).isRequired
    ).isRequired,
  onTodoClick: PropTypes.func.isRequired
}

export default TodoList
