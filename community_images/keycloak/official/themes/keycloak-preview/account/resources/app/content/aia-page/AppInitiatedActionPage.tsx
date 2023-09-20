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
import {withRouter, RouteComponentProps} from 'react-router-dom';

import {PageDef} from '../../ContentPages';
import {Msg} from '../../widgets/Msg';

import {
  Title,
  TitleLevel,
  Button,
  EmptyState,
  EmptyStateVariant,
  EmptyStateIcon,
  EmptyStateBody
} from '@patternfly/react-core';
import { PassportIcon } from '@patternfly/react-icons';
 
// Note: This class demonstrates two features of the ContentPages framework:
// 1) The PageDef is available as a React property.
// 2) You can add additional custom properties to the PageDef.  In this case,
//    we add a value called kcAction in content.js and access it by extending the
//    PageDef interface.
interface ActionPageDef extends PageDef {
    kcAction: string;
}

// Extend RouteComponentProps to get access to router information such as
// the hash-routed path associated with this page.  See this.props.location.pathname
// as used below.
interface AppInitiatedActionPageProps extends RouteComponentProps {
    pageDef: ActionPageDef;
}

declare const baseUrl: string;
declare const realm: string;
declare const referrer: string;
declare const referrerUri: string;

/**
 * @author Stan Silvert
 */
class ApplicationInitiatedActionPage extends React.Component<AppInitiatedActionPageProps> {
    
    public constructor(props: AppInitiatedActionPageProps) {
        super(props);
    }

    private handleClick = (): void => {
        let redirectURI: string = baseUrl;
        
        if (typeof referrer !== 'undefined') {
            // '_hash_' is a workaround for when uri encoding is not
            // sufficient to escape the # character properly.
            // The problem is that both the redirect and the application URL contain a hash.
            // The browser will consider anything after the first hash to be client-side.  So
            // it sees the hash in the redirect param and stops.
            redirectURI += "?referrer=" + referrer + "&referrer_uri=" + referrerUri.replace('#', '_hash_');
        }

        redirectURI = encodeURIComponent(redirectURI);
        
        const href: string = "/auth/realms/" + realm +
                             "/protocol/openid-connect/auth/" +
                             "?response_type=code" +
                             "&client_id=account&scope=openid" +
                             "&kc_action=" + this.props.pageDef.kcAction + 
                             "&silent_cancel=true" +
                             "&redirect_uri=" + redirectURI +
                             encodeURIComponent("/#" + this.props.location.pathname); // return to this page

        window.location.href = href;
    }

    public render(): React.ReactNode {
        return (
            <EmptyState variant={EmptyStateVariant.full}>
                <EmptyStateIcon icon={PassportIcon} />
                <Title headingLevel={TitleLevel.h5} size="lg">
                  <Msg msgKey={this.props.pageDef.label} params={this.props.pageDef.labelParams}/>
                </Title>
                <EmptyStateBody>
                  <Msg msgKey="actionRequiresIDP"/>
                </EmptyStateBody>
                <Button variant="primary"
                        onClick={this.handleClick}
                        target="_blank"><Msg msgKey="continue"/></Button>
            </EmptyState>
        );
    }
};

// Note that the class name is not exported above.  To get access to the router,
// we use withRouter() and export a different name.
export const AppInitiatedActionPage = withRouter(ApplicationInitiatedActionPage);