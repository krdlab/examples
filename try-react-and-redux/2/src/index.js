import { createStore } from 'redux'

const INC = 'INC'
const DEC = 'DEC'

function counter(state = 0, action) {
  switch (action.type) {
    case INC:
      return state + 1
    case DEC:
      return state - 1
    default:
      return state
  }
}

let store = createStore(counter)

store.subscribe(() => console.log(store.getState()) )

store.dispatch({ type: INC })
store.dispatch({ type: INC })
store.dispatch({ type: DEC })
