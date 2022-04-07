import React from "react";
import { compose } from "recompose";
import { connect } from "react-redux";
import withStyles from "@material-ui/core/styles/withStyles";
import FormLayout from "../../components/form-layout";
import SendForm from "./form";
import IconLabelTabs from "./form-tabs";
import Button from "@material-ui/core/Button";
import Loader from "../../components/loader";

const styles = (theme) => ({
  form: {
    width: "100%", // Fix IE11 issue.
    marginTop: theme.spacing.unit,
  },
  submit: {
    // marginTop: theme.spacing.unit * 3,
    backgroundColor: "#b9b9b9",
    "&:hover": {
      backgroundColor: "#48c648",
    },
    fontFamily: "TruenoRegular",
    fontWeight: "normal",
    fontStyle: "normal",
    borderRadius: 0,
    fontSize: 12,
    marginBottom: 10,
    marginTop: 40,
    // fontWeight:700
    width: "30%",
  },
  loginText: {
    fontFamily: "TruenoLight",
    fontWeight: "normal",
    fontStyle: "normal",
    textAlign: "center",
    color: "black",
  },
  inputField: {
    backgroundColor: "#fff",
    fontSize: 10,
    fontWeight: 700,
    paddingTop: 7,
    paddingBottom: 7,
    marginTop: 5,
    marginBottom: 5,
  },
});

const mapDispatchToProps = ({ sendMessage }) => {
  return {
    sendMessage: sendMessage.sendMessage,
    readWriteChain: sendMessage.readWriteChain,
    completeTransaction: sendMessage.completeTransaction,
    createSalePointTransaction: sendMessage.createSalePointTransaction,
    createPointTokenTransaction: sendMessage.createPointTokenTransaction,
  };
};

const mapStateToProps = ({ sendMessage }) => {
  return {
    ...sendMessage,
  };
};

const initialState = {
  errorMessages: {
    skuId: null,
    productId: null,
    allotNumber: null,
    inventoryAllotNumber: null,
    name: null,
    description: null,
    quantity: null,
    senderName: null,
    quantityAdjustment: null,
    adjustmentMessage: null,
    inventorySkuTransactionId: null,
    existingInventorySkuTransactionId: null,
    salesTransProp: null,
    claimRewardPoints: null,
    orderID: null,
    soldToUserID: null,
    soldToEmail: null,
    Cpts: null,
    Wpts: null,
    CHpts: null,
    WApts: null,
    Ckg: null,
    Wkg: null,
    CHkg: null,
    WAkg: null,
    useByName: null,
    docLink: null,
    docHash: null,
  },
  inventoryData: {
    skuId: "",
    productId: "",
    allotNumber: "",
    name: "",
    description: "",
    quantity: 0,
    senderName: "",
    quantityAdjustment: 0,
    adjustmentMessage: "",
    existingInventorySkuTransactionId: "",
    type: "inventory",
  },

  acceptData: {
    skuId: "",
    productId: "",
    inventoryAllotNumber: "",
    inventorySkuTransactionId: "",
    name: "",
    description: "",
    quantity: 0,
    senderName: "",
    acceptTransProp: "",
    quantityAdjustment: 0,
    adjustmentMessage: "",
    type: "accept",
  },

  saleData: {
    skuId: "",
    productId: "",
    inventorySkuTransactionId: "",
    quantity: 0,
    salesTransProp: "",
    claimRewardPoints: 0,
    soldToUserID: "",
    soldToEmail: "",
    soldByName: "",
    orderNumberId: "",
    type: "sale",
  },

  resaleData: {
    skuId: "",
    productId: "",
    saleSkuTransactionId: "",
    quantity: 0,
    soldByName: "",
    level4Use: "",
    orderNumberId: "",
    type: "resale",
  },

  reuseData: {
    skuId: "",
    productId: "",
    inventorySkuTransactionId: "",
    quantity: 0,
    reuseTransProp: "",
    useByName: "",
    docLink: "",
    docHash: "",
    type: "reuse",
  },

  recycleData: {
    skuId: "",
    productId: "",
    inventorySkuTransactionId: "",
    quantity: 0,
    recycleTransProp: "",
    useByName: "",
    docLink: "",
    docHash: "",
    type: "recycle",
  },

  salePointData: {
    pointID: "",
    C: "",
    W: "",
    CH: "",
    WA: "",
    type: "salePoint",
  },

  salePointAPIData: {
    orderID: "",
    soldToUserID: "",
    soldToEmail: "",
    soldByName: "",
    Cpts: "",
    Wpts: "",
    CHpts: "",
    WApts: "",
    Ckg: "",
    Wkg: "",
    CHkg: "",
    WAkg: "",
    type: "salePointAPI",
  },

  activeTab: 0,
  tabs: [
    "inventory",
    "accept",
    "sale",
    "resale",
    "reuse",
    "recycle",
    "salePointAPI",
    "salePoint",
  ],
};

class SendMessage extends React.Component {
  constructor(props) {
    super(props);
    this.state = initialState;
  }

  updateFormData(reset, prop, val, required, forformData) {
    this.setState((prevState) => {
      if (!reset) {
        const errorMessages = { ...prevState.errorMessages };
        const data = { ...prevState[forformData] };

        if (!val && required) {
          errorMessages[prop] = `Please enter ${prop}`;
        } else {
          errorMessages[prop] = null;
        }

        data[prop] = val;

        console.log(data);

        return {
          errorMessages,
          [forformData]: data,
        };
      } else {
        return { ...initialState };
      }
    });
  }

  checkQuantity(quantity) {
    if (quantity <= 0) {
      alert("Quantity cannot be zero");
      return false;
    }
    return true;
  }

  onSubmit(forformData) {
    console.log(forformData);

    console.log("activeTab => ", this.state.activeTab);

    const body = { ...this.state[forformData] };

    console.log(body);

    let canSubmit = true;

    if (body && body.hasOwnProperty("quantity")) {
      body.quantity = parseInt(body.quantity, 10);
    }

    if (body.hasOwnProperty("quantityAdjustment")) {
      body.quantityAdjustment = parseInt(body.quantityAdjustment, 10);
      if (body.quantityAdjustment === 0) {
        canSubmit = this.checkQuantity(body.quantity);
      }
    } else {
      canSubmit = this.checkQuantity(body.quantity);
    }

    if (canSubmit) {
      if (body.hasOwnProperty("claimRewardPoints")) {
        body.claimRewardPoints = parseInt(body.claimRewardPoints, 10);
      }

      Object.keys(body).forEach((key) => {
        if (body[key] === "") {
          body[key] = "null";
        }
      });

      console.log(body);

      let payload = {
        operation: "send_message",
        body,
      };

      let point = 0;

      if (this.state.activeTab === 7) {
        payload = {
          Body: {
            pointID: body.pointID,
            C: parseInt(body.C, 10),
            W: parseInt(body.W, 10),
            CH: parseInt(body.CH, 10),
            WA: parseInt(body.WA, 10),
          },
          Mode: "update",
        };
        point = 1;
      }

      if (this.state.activeTab === 6) {
        payload.operation = "set_points_data";

        point = 2;

        const points = ["Cpts", "Wpts", "CHpts", "WApts"];
        const kgs = ["Ckg", "Ckg", "Wkg", "CHkg", "WAkg"];
        const order = ["orderID", "soldToUserID", "soldToEmail", "soldByName"];

        const payloadBodyData = { ...payload.body };

        const pointAPIpayload = {
          points: {},
          kgs: {},
          order: {},
        };

        Object.keys(payloadBodyData).forEach((key) => {
          if (points.indexOf(key) !== -1) {
            pointAPIpayload["points"][key] = parseInt(payloadBodyData[key], 10);
          }

          if (kgs.indexOf(key) !== -1) {
            pointAPIpayload["kgs"][key] = payloadBodyData[key];
          }

          if (order.indexOf(key) !== -1) {
            pointAPIpayload["order"][key] = payloadBodyData[key];
          }
        });

        payload.body = { ...pointAPIpayload };
      }

      console.log("payload => ", payload);

      //call service to send reset link via email

      console.log("point", point);

      this.props.sendMessage(payload, point).then((res) => {
        console.log("res", res);
        if (this.props.resetForm) {
          this.setState({ [forformData]: initialState[forformData] });
        }
      });
    }
  }

  getTabFormControls() {
    let { classes } = this.props;

    const controls = [];

    const inventoryControlsKeys = [
      "skuId",
      "productId",
      "allotNumber",
      "name",
      "description",
      "quantity",
      "senderName",
      "quantityAdjustment",
      "adjustmentMessage",
      "existingInventorySkuTransactionId",
    ];

    const acceptControlsKeys = [
      "skuId",
      "productId",
      "inventoryAllotNumber",
      "inventorySkuTransactionId",
      "name",
      "description",
      "quantity",
      "senderName",
      "acceptTransProp",
      "quantityAdjustment",
      "adjustmentMessage",
    ];

    const saleControlsKeys = [
      "skuId",
      "productId",
      "inventorySkuTransactionId",
      "quantity",
      "salesTransProp",
      "claimRewardPoints",
      "soldToUserID",
      "soldToEmail",
      "soldByName",
      "orderNumberId",
    ];

    const resaleControlsKeys = [
      "skuId",
      "productId",
      "saleSkuTransactionId",
      "quantity",
      "soldByName",
      "level4Use",
      "orderNumberId",
    ];

    const salePointControlsKeys = ["pointID", "C", "W", "CH", "WA"];

    const salePointAPIControlKeys = [
      "orderID",
      "soldToUserID",
      "soldToEmail",
      "soldByName",
      "Cpts",
      "Wpts",
      "CHpts",
      "WApts",
      "Ckg",
      "Wkg",
      "CHkg",
      "WAkg",
    ];

    const reuseControlKeys = [
      "skuId",
      "productId",
      "inventorySkuTransactionId",
      "quantity",
      "reuseTransProp",
      "useByName",
      "docLink",
      "docHash",
    ];

    const recycleControlKeys = [
      "skuId",
      "productId",
      "inventorySkuTransactionId",
      "quantity",
      "recycleTransProp",
      "useByName",
      "docLink",
      "docHash",
    ];

    let currentTabKeysArray;

    switch (this.state.activeTab) {
      case 0:
        currentTabKeysArray = inventoryControlsKeys;
        break;
      case 1:
        currentTabKeysArray = acceptControlsKeys;
        break;
      case 2:
        currentTabKeysArray = saleControlsKeys;
        break;
      case 3:
        currentTabKeysArray = resaleControlsKeys;
        break;
      case 4:
        currentTabKeysArray = reuseControlKeys;
        break;
      case 5:
        currentTabKeysArray = recycleControlKeys;
        break;
      case 6:
        currentTabKeysArray = salePointAPIControlKeys;
        break;
      // case 7:
      //   currentTabKeysArray = salePointControlsKeys;
      //   break;

      default:
        currentTabKeysArray = inventoryControlsKeys;
    }

    for (let key of currentTabKeysArray) {
      let inputType = "input";
      let required = true;
      let dataType = "text";
      let minValue;

      if (key === "description" || key === "adjustmentMessage") {
        inputType = "textarea";
        dataType = null;
      }

      const numberKeys = [
        "quantity",
        "quantityAdjustment",
        "claimRewardPoints",
        "Cpts",
        "Wpts",
        "CHpts",
        "WApts",
      ];
      if (numberKeys.indexOf(key) !== -1) {
        dataType = "number";
        minValue = 0;
      }

      console.log("key", key);

      const optionalKeys = [
        "claimRewardPoints",
        "quantityAdjustment",
        "adjustmentMessage",
        "existingInventorySkuTransactionId",
        "acceptTransProp",
      ];

      if (optionalKeys.indexOf(key) !== -1) {
        required = false;
      }

      const control = {
        id: key,
        name: key,
        required,
        fullWidth: true,
        autoFocus: false,
        placeholder: `Enter ${key} `,
        className: classes.inputField,
        style: "",
        maxlength: "100",
        inputType,
        number: false,
        dataType,
        minValue,
      };

      controls.push(control);
    }
    return controls;
  }

  tabChangeHandler(value) {
    this.setState({
      errorMessages: { ...initialState.errorMessages },
      activeTab: value,
      //=== 4 ? 5 : value,
    });
  }

  render() {
    return (
      <FormLayout pageTitle="SKU Operations" header="">
        <div style={{ float: "right" }}>
          <Button
            type="button"
            variant="contained"
            color="secondary"
            className="btn-w-md"
            onClick={() => this.props.readWriteChain()}
            style={{ marginRight: "10px" }}
          >
            {this.props.readwriteRequestProcessing ? (
              <Loader />
            ) : (
              "Read Queue Write Chain"
            )}
          </Button>

          <Button
            type="button"
            variant="contained"
            color="secondary"
            className="btn-w-md"
            onClick={() => this.props.completeTransaction()}
            style={{ marginRight: "10px" }}
          >
            {this.props.completeRequestProcessing ? (
              <Loader />
            ) : (
              "Complete Transaction"
            )}
          </Button>

          <Button
            type="button"
            variant="contained"
            color="secondary"
            className="btn-w-md"
            onClick={() => this.props.createSalePointTransaction()}
            style={{ marginRight: "10px" }}
          >
            {this.props.createSalePointRequestProcessing ? (
              <Loader />
            ) : (
              "Create Sale/Resale Point"
            )}
          </Button>

          <Button
            type="button"
            variant="contained"
            color="secondary"
            className="btn-w-md"
            onClick={() => this.props.createPointTokenTransaction()}
            style={{ marginRight: "10px" }}
          >
            {this.props.createPointTokenRequestProcessing ? (
              <Loader />
            ) : (
              "Create Point Token"
            )}
          </Button>
        </div>
        <br />
        <br />
        <br />
        <IconLabelTabs
          setActiveTab={(value) => this.tabChangeHandler(value)}
          activeTab={this.state.activeTab}
        />
        <br />
        <SendForm
          formData={this.state[this.state.tabs[this.state.activeTab] + "Data"]}
          submitHandler={(event) =>
            this.onSubmit(this.state.tabs[this.state.activeTab] + "Data")
          }
          changeHandler={(reset, name, val, required) =>
            this.updateFormData(
              reset,
              name,
              val,
              required,
              this.state.tabs[this.state.activeTab] + "Data"
            )
          }
          activeTab={this.state.activeTab}
          controls={this.getTabFormControls()}
          loading={this.props.loading}
          errorMessages={this.state.errorMessages}
        />
      </FormLayout>
    );
  }
}

export default compose(
  connect(mapStateToProps, mapDispatchToProps),
  withStyles(styles, { withTheme: true })
)(SendMessage);
