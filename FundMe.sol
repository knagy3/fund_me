// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// It is not needed from sol 0.8
// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    uint256 public minimumUSD;

    constructor() public {
        // msg.sender will be the contract deployer
        owner = msg.sender;
    }
    
    function fund() public payable {
        // 5 USD threshold
        minimumUSD = 5 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        // Ignores the othe return values
        (,int256 answer,,,) = priceFeed.latestRoundData();
         return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    } 

    // Modifier is used to change the bahvior of a function
    // in a declerative way.
    modifier onlyOwner {
        require(msg.sender == owner);
        // it means the require runs first
        _;
    }
    
    function withdraw()  payable onlyOwner public {
        // withdraw all the money
        payable(msg.sender).transfer(address(this).balance);
        // loop through the funders
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
