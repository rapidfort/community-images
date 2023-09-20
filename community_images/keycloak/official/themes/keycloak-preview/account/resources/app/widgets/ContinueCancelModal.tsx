/* 
 * Copyright 2019 Red Hat, Inc. and/or its affiliates.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import * as React from 'react';
import { Modal, Button, ButtonProps } from '@patternfly/react-core';
import {Msg} from './Msg';
 
/**
 * For any of these properties that are strings, you can
 * pass in a localization key instead of a static string.
 */
interface ContinueCancelModalProps {
    buttonTitle: string;
    buttonVariant?: ButtonProps['variant'];
    modalTitle: string;
    modalMessage: string;
    modalContinueButtonLabel?: string;
    modalCancelButtonLabel?: string;
    onContinue: () => void;
}

interface ContinueCancelModalState {
    isModalOpen: boolean;
}

/**
 * This class renders a button that provides a continue/cancel modal dialog when clicked.  If the user selects 'Continue'
 * then the onContinue function is executed.
 * 
 * @author Stan Silvert ssilvert@redhat.com (C) 2019 Red Hat Inc.
 */
export class ContinueCancelModal extends React.Component<ContinueCancelModalProps, ContinueCancelModalState> {
    protected static defaultProps = {
        buttonVariant: 'primary',
        modalContinueButtonLabel: 'continue',
        modalCancelButtonLabel: 'doCancel'
    };
    
    public constructor(props: ContinueCancelModalProps) {
        super(props);
        this.state = {
            isModalOpen: false
        };
    }

    private handleModalToggle = () => {
        this.setState(({ isModalOpen }) => ({
            isModalOpen: !isModalOpen
        }));
    };

    private handleContinue  = () => {
        this.handleModalToggle();
        this.props.onContinue();
    }

    public render(): React.ReactNode {
        const { isModalOpen } = this.state;

        return (
            <React.Fragment>
                <Button variant={this.props.buttonVariant} onClick={this.handleModalToggle}>
                    <Msg msgKey={this.props.buttonTitle}/>
                </Button>
                <Modal
                    isSmall
                    title={Msg.localize(this.props.modalTitle)}
                    isOpen={isModalOpen}
                    onClose={this.handleModalToggle}
                    actions={[
                        <Button key="cancel" variant="secondary" onClick={this.handleModalToggle}>
                            <Msg msgKey={this.props.modalCancelButtonLabel!}/>
                        </Button>,
                        <Button key="confirm" variant="primary" onClick={this.handleContinue}>
                            <Msg msgKey={this.props.modalContinueButtonLabel!}/>
                        </Button>
                    ]}
                >
                    <Msg msgKey={this.props.modalMessage}/>
                </Modal>
            </React.Fragment>
        );
    }
};