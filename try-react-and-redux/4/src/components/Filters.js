import React from 'react'
import FilterLink from '../containers/FilterLink'
import Navigation from 'react-toolbox/lib/navigation'

const Filters = () => (
  <Navigation type='horizontal'>
    <FilterLink filter="SHOW_ALL" label="All" />
    <FilterLink filter="SHOW_ACTIVE" label="Active" />
    <FilterLink filter="SHOW_COMPLETED" label="Completed" />
  </Navigation>
)

export default Filters
