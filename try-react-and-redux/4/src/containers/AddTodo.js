import React from 'react'
import { connect } from 'react-redux'
import { addTodo } from '../actions'
import { Input } from 'react-toolbox/lib/input'
import { Button } from 'react-toolbox/lib/button'

class AddTodo extends React.Component {
  constructor() {
    super()
    this.state = { todo: '' }
    this.handleChange = this.handleChange.bind(this)
  }

  handleChange(value) {
    this.setState({ todo: value })
  }

  render() {
    return (
      <div>
        <form onSubmit={e => {
          e.preventDefault()
          if (!this.state.todo.trim()) {
            return
          }
          this.props.dispatch(addTodo(this.state.todo))
          this.handleChange('')
        }}>
          <Input type='text' label='todo' name='todo' value={this.state.todo} onChange={this.handleChange} />
          <Button icon='add' label='Add todo' flat primary mini />
        </form>
      </div>
    )
  }
}

AddTodo = connect()(AddTodo)

export default AddTodo
