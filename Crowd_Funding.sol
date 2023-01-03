// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Project_Funding{
     mapping(address=>uint) public contributors;
     address public manager;
     uint public raiseamount;
     uint public totalcontributors;
     uint public minamount;
     uint target;
     uint deadline;
struct Request{
         string description;
         address payable recipient;
         uint value;
         bool iscompleted;
         uint totalvoters;
         mapping(address=>bool)  voters;
     }
     mapping(uint=>Request) public requests;
     uint public total_requests;
     constructor(uint _target, uint _deadline){
                target=_target;
                manager=msg.sender;
                deadline=block.timestamp + _deadline;
                minamount=150 wei;
}


          function SendEth() public payable{
              require(block.timestamp < deadline , "Contract Ended");
              require(msg.value >= minamount);

              if(contributors[msg.sender]==0){
                  totalcontributors++;
              }
              contributors[msg.sender]+=msg.value;
              raiseamount+=msg.value;
          }    
          function GetBalance() public view returns(uint){
              return address(this).balance;
          }

          function refund() public payable{
              require(block.timestamp > deadline && raiseamount<target,"hi");
              require(contributors[msg.sender]>0,"oh");
              address payable user=payable(msg.sender); 
              user.transfer(contributors[msg.sender]);
              contributors[msg.sender]=0;
}

          modifier onlymanager(){
              require(msg.sender==manager);
              _;
          }     
          function CreateRequest(string memory description, uint value,address payable recipient)  public onlymanager{
           Request storage newrequest= requests[total_requests];
           total_requests++;
           newrequest.description=description;
           newrequest.value=value;
           newrequest.recipient=recipient;
           newrequest.iscompleted=false;
           newrequest.totalvoters=0;
          }               
          function Vote(uint _requestnum) public{
             require(contributors[msg.sender]>0,"You have to contribute first");
             Request storage thisrequest=requests[_requestnum];
             require(thisrequest.voters[msg.sender]==false);
             thisrequest.voters[msg.sender]=true;
             thisrequest.totalvoters++;
}    

            function makePayment(uint numreq) public onlymanager{
                require(raiseamount>=target,"target doesn't matched");
                Request storage thisreq=requests[numreq];
                require(thisreq.iscompleted==false);
                require(thisreq.totalvoters>=totalcontributors/2,"not allowed");
                thisreq.recipient.transfer(thisreq.value);
                thisreq.iscompleted=true;
}
}
