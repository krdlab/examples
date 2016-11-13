import React, { PropTypes } from 'react'
import { ListItem } from 'react-toolbox/lib/list'

const Todo = ({ onClick, completed, text }) => (
  <ListItem caption={text} selectable onClick={onClick} disabled={completed} />
)

Todo.propTypes = {
  onClick:    PropTypes.func.isRequired,
  completed:  PropTypes.bool.isRequired,
  text:       PropTypes.string.isRequired
}

export default Todo
