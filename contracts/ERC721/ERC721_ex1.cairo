%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin

from starkware.cairo.common.math import assert_not_zero

from openzeppelin.token.erc721.library import ERC721

from contracts.utils.ex00_base import (
    tderc20_address,
    distribute_points,
    ex_initializer,
    has_validated_exercise,
    validate_exercise,
)

from contracts.token.ERC721.IERC721 import IERC721
from contracts.token.ERC721.IERC721_metadata import IERC721_metadata
from contracts.IExerciseSolution import IExerciseSolution
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_le,
    uint256_lt,
    uint256_check,
    uint256_eq,
)
from contracts.token.ERC20.ITDERC20 import ITDERC20
from contracts.token.ERC20.IERC20 import IERC20

//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _tderc20_address: felt,
    _players_registry: felt,
    _workshop_id: felt,
    dummy_metadata_erc721_address: felt,
    _dummy_token_address: felt,
    name: felt, 
    symbol: felt, 
    to_: felt
) {
    ex_initializer(_tderc20_address, _players_registry, _workshop_id);
    dummy_token_address_storage.write(_dummy_token_address);
    dummy_metadata_erc721_storage.write(dummy_metadata_erc721_address);
    // Hard coded value for now
    max_rank_storage.write(100);
    ERC721.initializer(name, symbol);
    let to = to_;
    let token_id: Uint256 = Uint256(1, 0);
    ERC721._mint(to, token_id);
    return ();
}

//
// Declaring storage vars
// Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
//

@storage_var
func has_been_paired(contract_address: felt) -> (has_been_paired: felt) {
}

@storage_var
func player_exercise_solution_storage(player_address: felt) -> (contract_address: felt) {
}

@storage_var
func assigned_rank_storage(player_address: felt) -> (rank: felt) {
}

@storage_var
func next_rank_storage() -> (next_rank: felt) {
}

@storage_var
func max_rank_storage() -> (max_rank: felt) {
}

@storage_var
func random_attributes_storage(column: felt, rank: felt) -> (value: felt) {
}

@storage_var
func was_initialized() -> (was_initialized: felt) {
}

@storage_var
func dummy_token_address_storage() -> (dummy_token_address_storage: felt) {
}

@storage_var
func dummy_metadata_erc721_storage() -> (dummy_metadata_erc721_storage: felt) {
}



//
// Getters
//

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (owner: felt) {
    let (owner: felt) = ERC721.owner_of(token_id);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(token_id);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (is_approved: felt) {
    let (is_approved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (is_approved,);
}

//
// Externals
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, token_id: Uint256
) {
    ERC721.approve(to, token_id);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256
) {
    ERC721.transfer_from(_from, to, token_id);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256, data_len: felt, data: felt*
) {
    ERC721.safe_transfer_from(_from, to, token_id, data_len, data);
    return ();
}
