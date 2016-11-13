import React from 'react'
import Filters from './Filters'
import AddTodo from '../containers/AddTodo'
import VisibleTodoList from '../containers/VisibleTodoList'

const App = () => (
  <div>
    <AddTodo />
    <Filters />
    <VisibleTodoList />
  </div>
)

export default App
