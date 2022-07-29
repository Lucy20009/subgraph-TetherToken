// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  ethereum,
  JSONValue,
  TypedMap,
  Entity,
  Bytes,
  Address,
  BigInt
} from "@graphprotocol/graph-ts";

export class NewGravatar extends ethereum.Event {
  get params(): NewGravatar__Params {
    return new NewGravatar__Params(this);
  }
}

export class NewGravatar__Params {
  _event: NewGravatar;

  constructor(event: NewGravatar) {
    this._event = event;
  }

  get id(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get owner(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get receiver(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get money(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }
}

export class Gravity__gravatarsResult {
  value0: Address;
  value1: Address;
  value2: BigInt;

  constructor(value0: Address, value1: Address, value2: BigInt) {
    this.value0 = value0;
    this.value1 = value1;
    this.value2 = value2;
  }

  toMap(): TypedMap<string, ethereum.Value> {
    let map = new TypedMap<string, ethereum.Value>();
    map.set("value0", ethereum.Value.fromAddress(this.value0));
    map.set("value1", ethereum.Value.fromAddress(this.value1));
    map.set("value2", ethereum.Value.fromUnsignedBigInt(this.value2));
    return map;
  }

  getOwner(): Address {
    return this.value0;
  }

  getReceiver(): Address {
    return this.value1;
  }

  getMoney(): BigInt {
    return this.value2;
  }
}

export class Gravity extends ethereum.SmartContract {
  static bind(address: Address): Gravity {
    return new Gravity("Gravity", address);
  }

  gravatars(param0: BigInt): Gravity__gravatarsResult {
    let result = super.call(
      "gravatars",
      "gravatars(uint256):(address,address,uint256)",
      [ethereum.Value.fromUnsignedBigInt(param0)]
    );

    return new Gravity__gravatarsResult(
      result[0].toAddress(),
      result[1].toAddress(),
      result[2].toBigInt()
    );
  }

  try_gravatars(param0: BigInt): ethereum.CallResult<Gravity__gravatarsResult> {
    let result = super.tryCall(
      "gravatars",
      "gravatars(uint256):(address,address,uint256)",
      [ethereum.Value.fromUnsignedBigInt(param0)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      new Gravity__gravatarsResult(
        value[0].toAddress(),
        value[1].toAddress(),
        value[2].toBigInt()
      )
    );
  }
}

export class CreateGravatarCall extends ethereum.Call {
  get inputs(): CreateGravatarCall__Inputs {
    return new CreateGravatarCall__Inputs(this);
  }

  get outputs(): CreateGravatarCall__Outputs {
    return new CreateGravatarCall__Outputs(this);
  }
}

export class CreateGravatarCall__Inputs {
  _call: CreateGravatarCall;

  constructor(call: CreateGravatarCall) {
    this._call = call;
  }

  get _owner(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get _receiver(): Address {
    return this._call.inputValues[1].value.toAddress();
  }

  get _money(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }
}

export class CreateGravatarCall__Outputs {
  _call: CreateGravatarCall;

  constructor(call: CreateGravatarCall) {
    this._call = call;
  }
}
