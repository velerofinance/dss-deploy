pragma solidity >=0.5.12;

import {DSTest} from "ds-test/test.sol";
import {DSToken} from "ds-token/token.sol";
import {DSValue} from "ds-value/value.sol";
import {GemJoin} from "dss/join.sol";

import "./DssDeploy.sol";
import {GovActions} from "./govActions.sol";

interface Hevm {
    function warp(uint256) external;
}

interface AuctionLike {
    function tend(uint, uint, uint) external;
    function dent(uint, uint, uint) external;
    function deal(uint) external;
}

interface HopeLike {
    function hope(address guy) external;
}

contract WVLX is DSToken("WVLX") {
}

contract FakeUser {
    function doApprove(address token, address guy) public {
        DSToken(token).approve(guy);
    }

    function doUsdvJoin(address obj, address urn, uint wad) public {
        USDVJoin(obj).join(urn, wad);
    }

    function doUsdvExit(address obj, address guy, uint wad) public {
        USDVJoin(obj).exit(guy, wad);
    }

    function doWvlxJoin(address obj, address gem, address urn, uint wad) public {
        WVLX(obj).approve(address(gem), uint(-1));
        GemJoin(gem).join(urn, wad);
    }

    function doFrob(address obj, bytes32 ilk, address urn, address gem, address usdv, int dink, int dart) public {
        Vat(obj).frob(ilk, urn, gem, usdv, dink, dart);
    }

    function doFork(address obj, bytes32 ilk, address src, address dst, int dink, int dart) public {
        Vat(obj).fork(ilk, src, dst, dink, dart);
    }

    function doHope(address obj, address guy) public {
        HopeLike(obj).hope(guy);
    }

    function doTend(address obj, uint id, uint lot, uint bid) public {
        AuctionLike(obj).tend(id, lot, bid);
    }

    function doDent(address obj, uint id, uint lot, uint bid) public {
        AuctionLike(obj).dent(id, lot, bid);
    }

    function doDeal(address obj, uint id) public {
        AuctionLike(obj).deal(id);
    }

    function doEndFree(address end, bytes32 ilk) public {
        End(end).free(ilk);
    }

    function doESMJoin(address gem, address esm, uint256 wad) public {
        DSToken(gem).approve(esm, uint256(-1));
        ESM(esm).join(wad);
    }
}

contract ProxyActions {
    DSPause pause;
    GovActions govActions;

    function rely(address from, address to) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("rely(address,address)", from, to);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function deny(address from, address to) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("deny(address,address)", from, to);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function file(address who, bytes32 what, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("file(address,bytes32,uint256)", who, what, data);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function file(address who, bytes32 ilk, bytes32 what, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("file(address,bytes32,bytes32,uint256)", who, ilk, what, data);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function dripAndFile(address who, bytes32 what, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("dripAndFile(address,bytes32,uint256)", who, what, data);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function dripAndFile(address who, bytes32 ilk, bytes32 what, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("dripAndFile(address,bytes32,bytes32,uint256)", who, ilk, what, data);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function cage(address end) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("cage(address)", end);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function setAuthority(address newAuthority) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("setAuthority(address,address)", pause, newAuthority);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function setDelay(uint newDelay) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("setDelay(address,uint256)", pause, newDelay);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }

    function setAuthorityAndDelay(address newAuthority, uint newDelay) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("setAuthorityAndDelay(address,address,uint256)", pause, newAuthority, newDelay);
        uint         eta = now;

        pause.plot(usr, tag, fax, eta);
        pause.exec(usr, tag, fax, eta);
    }
}

contract MockGuard {
    mapping (address => mapping (address => mapping (bytes4 => bool))) acl;

    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool) {
        return acl[src][dst][sig];
    }

    function permit(address src, address dst, bytes4 sig) public {
        acl[src][dst][sig] = true;
    }
}

contract DssDeployTestBase is DSTest, ProxyActions {
    Hevm hevm;

    VatFab vatFab;
    JugFab jugFab;
    VowFab vowFab;
    CatFab catFab;
    USDVFab usdvFab;
    UsdvJoinFab usdvJoinFab;
    FlapFab flapFab;
    FlopFab flopFab;
    FlipFab flipFab;
    SpotFab spotFab;
    PotFab potFab;
    EndFab endFab;
    ESMFab esmFab;
    PauseFab pauseFab;

    DssDeploy dssDeploy;

    DSToken gov;
    DSValue pipVLX;
    DSValue pipCOL;

    MockGuard authority;

    WVLX wvlx;
    GemJoin vlxJoin;
    GemJoin colJoin;

    Vat vat;
    Jug jug;
    Vow vow;
    Cat cat;
    Flapper flap;
    Flopper flop;
    Token usdv;
    USDVJoin usdvJoin;
    Spotter spotter;
    Pot pot;
    End end;
    ESM esm;

    Flipper vlxFlip;

    DSToken col;
    Flipper colFlip;

    FakeUser user1;
    FakeUser user2;

    // --- Math ---
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;
    uint256 constant RAD = 10 ** 45;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function setUp() public {
        vatFab = new VatFab();
        jugFab = new JugFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        usdvFab = new USDVFab();
        usdvJoinFab = new UsdvJoinFab();
        flapFab = new FlapFab();
        flopFab = new FlopFab();
        flipFab = new FlipFab();
        spotFab = new SpotFab();
        potFab = new PotFab();
        endFab = new EndFab();
        esmFab = new ESMFab();
        pauseFab = new PauseFab();
        govActions = new GovActions();

        dssDeploy = new DssDeploy(
            vatFab,
            jugFab,
            vowFab,
            catFab,
            usdvFab,
            usdvJoinFab,
            flapFab,
            flopFab,
            flipFab,
            spotFab,
            potFab,
            endFab,
            esmFab,
            pauseFab
        );

        gov = new DSToken("GOV");
        gov.setAuthority(DSAuthority(address(new MockGuard())));
        pipVLX = new DSValue();
        pipCOL = new DSValue();
        authority = new MockGuard();

        user1 = new FakeUser();
        user2 = new FakeUser();

        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(0);
    }

    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }

    function deployKeepAuth() public {
        dssDeploy.deployVat();
        dssDeploy.deployUsdv(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployLiquidator();
        dssDeploy.deployShutdown(address(gov), address(0x0), 10);
        dssDeploy.deployPause(0, address(authority));

        vat = dssDeploy.vat();
        jug = dssDeploy.jug();
        vow = dssDeploy.vow();
        cat = dssDeploy.cat();
        flap = dssDeploy.flap();
        flop = dssDeploy.flop();
        usdv = dssDeploy.usdv();
        usdvJoin = dssDeploy.usdvJoin();
        spotter = dssDeploy.spotter();
        pot = dssDeploy.pot();
        end = dssDeploy.end();
        esm = dssDeploy.esm();
        pause = dssDeploy.pause();
        authority.permit(address(this), address(pause), bytes4(keccak256("plot(address,bytes32,bytes,uint256)")));

        wusdt = new WVLX();
        vlxJoin = new GemJoin(address(vat), "VLX", address(wusdt));
        dssDeploy.deployCollateral("VLX", address(vlxJoin), address(pipVLX));

        col = new DSToken("COL");
        colJoin = new GemJoin(address(vat), "COL", address(col));
        dssDeploy.deployCollateral("COL", address(colJoin), address(pipCOL));

        // Set Params
        this.file(address(vat), bytes32("Line"), uint(10000 * 10 ** 45));
        this.file(address(vat), bytes32("VLX"), bytes32("line"), uint(10000 * 10 ** 45));
        this.file(address(vat), bytes32("COL"), bytes32("line"), uint(10000 * 10 ** 45));

        pipVLX.poke(bytes32(uint(300 * 10 ** 18))); // Price 300 USDV = 1 VLX (precision 18)
        pipCOL.poke(bytes32(uint(45 * 10 ** 18))); // Price 45 USDV = 1 COL (precision 18)
        (vlxFlip,) = dssDeploy.ilks("VLX");
        (colFlip,) = dssDeploy.ilks("COL");
        this.file(address(spotter), "VLX", "mat", uint(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(spotter), "COL", "mat", uint(1100000000 ether)); // Liquidation ratio 110%
        spotter.poke("VLX");
        spotter.poke("COL");
        (,,uint spot,,) = vat.ilks("VLX");
        assertEq(spot, 300 * RAY * RAY / 1500000000 ether);
        (,, spot,,) = vat.ilks("COL");
        assertEq(spot, 45 * RAY * RAY / 1100000000 ether);

        MockGuard(address(gov.authority())).permit(address(flop), address(gov), bytes4(keccak256("mint(address,uint256)")));
        MockGuard(address(gov.authority())).permit(address(flap), address(gov), bytes4(keccak256("burn(address,uint256)")));

        gov.mint(100 ether);
    }

    function deploy() public {
        deployKeepAuth();
        dssDeploy.releaseAuth();
    }
}
