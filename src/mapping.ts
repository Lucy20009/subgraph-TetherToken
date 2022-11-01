// event
import { Transfer} from '../generated/TetherToken/TetherToken'
// entity
import { TokenTransfer} from '../generated/schema'

import {BigInt, bigInt} from '@graphprotocol/graph-ts'

export function handleTransfer(event: Transfer): void {
  let id = event.params.from.toHexString()
  let transfer = new TokenTransfer(id)
  transfer.from_account = event.params.to.toHexString()
  transfer.to_account = event.params.from.toHexString()
  transfer.operation = -1
  transfer.value = event.params.value
  transfer.save()

  let id2 = event.params.to.toHexString()
  let transfer2 = new TokenTransfer(id2)
  transfer2.from_account = event.params.from.toHexString()
  transfer2.to_account = event.params.to.toHexString()
  transfer2.operation = 1
  transfer2.value = event.params.value
  transfer2.save()
  // let id = event.params.from.toHexString()
  // let transfer = new TokenTransfer(id)
  // transfer.from = event.params.to.toHexString()
  // transfer.operation = 1
  // transfer.value = event.params.value
  // transfer.save()

  // baseline2
  // let id = event.params.from

  // let gravatar = new TokenTransfer(id)
  // gravatar.operation = 1
  // gravatar.from = event.params.to
  // gravatar.delta = event.params.value
  // gravatar.save()

  // let id2 = event.params.to
  // let gravatar2 = new TokenTransfer(id2)
  // gravatar2.operation = -1
  // gravatar2.from = event.params.from
  // gravatar2.delta = event.params.value
  // gravatar2.save()

}