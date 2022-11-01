/**
 *Submitted for verification at Etherscan.io on 2017-11-28
*/

pragma solidity ^0.4.17;

/**
 * @title SafeMath
 * @dev 具有引发错误的安全检查的数学运算
 */
library SafeMath {
  // 乘法
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    // 除法
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    // 减法
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    // 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev Ownable 合约有一个所有者地址，并提供基本的授权控制功能，这简化了“用户权限”的实现。
 */
contract Ownable {
    address public owner;

    /**
      * @dev Ownable 构造函数将合约的原始“所有者”设置为发送者帐户。
      */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
      * @dev 如果由所有者以外的任何帐户调用，则抛出。
      */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev 允许当前所有者将合约的控制权转移给新所有者。
    * @param newOwner 将所有权转移到的地址。
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

/**
 * @title ERC20Basic
 * @dev 简化版ERC20接口(ERC-20代币是一种代币标准)
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
    uint public _totalSupply;
    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed id, address indexed to, uint value);
}

/**
 * @title ERC20 接口
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * @title Basic token
 * @dev StandardToken 的基本版本，没有配额。
 */
contract BasicToken is Ownable, ERC20Basic {
    using SafeMath for uint;

    mapping(address => uint) public balances;

    // 如果需要交易费用时使用的额外变量
    uint public basisPointsRate = 0;
    uint public maximumFee = 0;

    /**
    * @dev 修复 ERC20 短地址攻击。
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    /**
    * @dev 转移指定地址的令牌
    * @param _to 要转移到的地址。
    * @param _value 要转移的金额。
    */
    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = _value.sub(fee);
        // 转出账户扣除金额
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // 转入账户增加金额（不包含fee）
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            // token所有者获得fee 
            balances[owner] = balances[owner].add(fee);
            // 吐出事件
            Transfer(msg.sender, owner, fee);
        }
        // 吐出事件
        Transfer(msg.sender, _to, sendAmount);
    }

    /**
    * @dev 获取指定地址的余额。
    * @param _owner 查询余额的地址。
    * @return An uint 表示传递的地址拥有的金额。
    */
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev 基本标准代币的实现。
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based oncode by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;

    /**
    * @dev 将代币从一个地址转移到另一个地址
    * @param _from address 您要发送代币的地址
    * @param _to address 您要转入的地址
    * @param _value uint 要转移的代币数量
    */
    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        var _allowance = allowed[_from][msg.sender];

        // 不需要检查，因为如果不满足此条件， sub(_allowance, _value) 将已经抛出
        // 如果 (_value > _allowance) 抛出;

        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        uint sendAmount = _value.sub(fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            Transfer(_from, owner, fee);
        }
        Transfer(_from, _to, sendAmount);
    }

    /**
    * @dev 批准传递的地址代表 msg.sender 花费指定数量的代币。
    * @param _spender 将花费资金的地址。
    * @param _value 要花费的代币数量。
    */
    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {

        // 要更改批准金额，您首先必须通过调用 `approve(_spender, 0)` 将地址限额减少为零，
        // 如果它还不是 0 以缓解此处描述的竞争条件：
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    /**
    * @dev 检查代币数量超过所有者允许消费者的功能。
    * @param _owner address 拥有资金的地址。
    * @param _spender address 将花费资金的地址。
    * @return A uint 指定仍然可供消费者使用的代币数量。
    */
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}


/**
 * @title Pausable
 * @dev 允许儿童实施紧急停止机制的基本合同。
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev 允许儿童实施紧急停止机制的基本合同。
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev 仅在合约暂停时使函数可调用的修饰符。
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev 被所有者调用暂停，触发停止状态
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev 由所有者调用以取消暂停，返回正常状态
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract BlackList is Ownable, BasicToken {

    // Getter 允许其他合约（包括升级后的 Tether）也使用相同的黑名单
    function getBlackListStatus(address _maker) external constant returns (bool) {
        return isBlackListed[_maker];
    }

    function getOwner() external constant returns (address) {
        return owner;
    }

    mapping (address => bool) public isBlackListed;
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        RemovedBlackList(_clearedUser);
    }

    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}

contract UpgradedStandardToken is StandardToken{
    // 这些方法由旧合约调用，它们必须确保 msg.sender 是合约地址
    function transferByLegacy(address from, address to, uint value) public;
    function transferFromByLegacy(address sender, address from, address spender, uint value) public;
    function approveByLegacy(address from, address spender, uint value) public;
}

contract TetherToken is Pausable, StandardToken, BlackList {

    string public name;
    string public symbol;
    uint public decimals;
    address public upgradedAddress;
    bool public deprecated;

    // 合约可以用多个代币初始化
    // 所有代币都存入所有者地址
    //
    // @param _balance 合同的初始供应
    // @param _name 代币名称
    // @param _symbol 代币符号
    // @param _decimals 代币小数
    function TetherToken(uint _initialSupply, string _name, string _symbol, uint _decimals) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
        deprecated = false;
    }

    // 如果不推荐使用此方法，则将 ERC20 方法转发到升级合约
    function transfer(address _to, uint _value) public whenNotPaused {
        // 不在黑名单内
        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            return super.transfer(_to, _value);
        }
    }

    // 如果不推荐使用此方法，则将 ERC20 方法转发到升级合约
    function transferFrom(address _from, address _to, uint _value) public whenNotPaused {
        require(!isBlackListed[_from]);
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
        } else {
            return super.transferFrom(_from, _to, _value);
        }
    }

    // 如果不推荐使用此方法，则将 ERC20 方法转发到升级合约
    function balanceOf(address who) public constant returns (uint) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    // 如果不推荐使用此方法，则将 ERC20 方法转发到升级合约
    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
        } else {
            return super.approve(_spender, _value);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        if (deprecated) {
            return StandardToken(upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }

    // 弃用当前合同以支持新合同
    function deprecate(address _upgradedAddress) public onlyOwner {
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        Deprecate(_upgradedAddress);
    }

    // 如果支持新合同，则弃用当前合同
    function totalSupply() public constant returns (uint) {
        if (deprecated) {
            return StandardToken(upgradedAddress).totalSupply();
        } else {
            return _totalSupply;
        }
    }

    // 发行新数量的代币，这些代币存入所有者地址
    //
    // @param _amount Number of tokens to be issued
    function issue(uint amount) public onlyOwner {
        require(_totalSupply + amount > _totalSupply);
        require(balances[owner] + amount > balances[owner]);

        balances[owner] += amount;
        _totalSupply += amount;
        Issue(amount);
    }

    // 兑换代币。
    // 如果余额必须足以支付赎回，则这些代币将从所有者地址中提取，否则调用将失败。
    // @param _amount Number of tokens to be issued
    function redeem(uint amount) public onlyOwner {
        require(_totalSupply >= amount);
        require(balances[owner] >= amount);

        _totalSupply -= amount;
        balances[owner] -= amount;
        Redeem(amount);
    }

    function setParams(uint newBasisPoints, uint newMaxFee) public onlyOwner {
        // 通过硬编码限制确保透明度，超过该限制永远不会增加费用
        require(newBasisPoints < 20);
        require(newMaxFee < 50);

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(10**decimals);

        Params(basisPointsRate, maximumFee);
    }

    // Called when new token are issued
    event Issue(uint amount);

    // Called when tokens are redeemed
    event Redeem(uint amount);

    // Called when contract is deprecated
    event Deprecate(address newAddress);

    // Called if contract ever adds fees
    event Params(uint feeBasisPoints, uint maxFee);
}