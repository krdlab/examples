import React, { PropTypes } from 'react'
import { Link as TLink } from 'react-toolbox/lib/link'

const Link = ({ active, onClick, label }) => {
  if (active) {
    return <TLink active href="#" label={label} onClick={e => {e.preventDefault()}} />
  } else {
    return (
      <TLink href="#" onClick={e => {
        e.preventDefault()
        onClick()
      }} label={label} />
    )
  }
}

Link.PropTypes = {
  active:   PropTypes.bool.isRequired,
  onClick:  PropTypes.func.isRequired
}

export default Link
