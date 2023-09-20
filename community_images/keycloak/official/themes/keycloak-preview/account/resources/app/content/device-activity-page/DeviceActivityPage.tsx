/* 
 * Copyright 2018 Red Hat, Inc. and/or its affiliates.
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
import * as moment from 'moment';
import {AxiosResponse} from 'axios';

import {AccountServiceClient} from '../../account-service/account.service';

import {
  Bullseye,
  DataList,
  DataListItem,
  DataListItemRow,
  DataListCell,
  DataListItemCells,
  Grid,
  GridItem,
  Stack,
  StackItem
} from '@patternfly/react-core';

import {
        AmazonIcon, 
        ChromeIcon, 
        EdgeIcon, 
        FirefoxIcon, 
        GlobeIcon,
        InternetExplorerIcon, 
        OperaIcon,
        SafariIcon,
        YandexInternationalIcon, 
} from '@patternfly/react-icons';

import {Msg} from '../../widgets/Msg';
import {ContinueCancelModal} from '../../widgets/ContinueCancelModal';
import {KeycloakService} from '../../keycloak-service/keycloak.service';
import {ContentPage} from '../ContentPage';
import { ContentAlert } from '../ContentAlert';
 
declare const baseUrl: string;

export interface DeviceActivityPageProps {
}

export interface DeviceActivityPageState {
  devices: Device[];
}

interface Device {
  browser: string;
  current: boolean;
  device: string;
  ipAddress: string;
  lastAccess: number;
  mobile: boolean;
  os: string;
  osVersion: string;
  sessions: Session[];
}

interface Session {
  browser: string;
  current: boolean;
  clients: Client[];
  expires: number;
  id: string;
  ipAddress: string;
  lastAccess: number;
  started: number;
}

interface Client {
  clientId: string;
  clientName: string;
}
 
/**
 * @author Stan Silvert ssilvert@redhat.com (C) 2019 Red Hat Inc.
 */
export class DeviceActivityPage extends React.Component<DeviceActivityPageProps, DeviceActivityPageState> {
 
    public constructor(props: DeviceActivityPageProps) {
        super(props);

        this.state = {
          devices: []
        };

        this.fetchDevices();
    }

    private signOutAll = () => {
      AccountServiceClient.Instance.doDelete("/sessions")
        .then( () => {
          KeycloakService.Instance.logout(baseUrl);
        });
    }

    private signOutSession = (device: Device, session: Session) => {
      AccountServiceClient.Instance.doDelete("/sessions/" + session.id)
          .then (() => {
            this.fetchDevices();
            ContentAlert.success(Msg.localize('signedOutSession', [session.browser, device.os]));
          });
    }

    private fetchDevices(): void {
      AccountServiceClient.Instance.doGet("/sessions/devices")
          .then((response: AxiosResponse<Device[]>) => {
            console.log({response});

            let devices: Device[] = this.moveCurrentToTop(response.data);
            
            this.setState({
              devices: devices
            });
            
          });
    }

    // current device and session should display at the top of their respective lists
    private moveCurrentToTop(devices: Device[]): Device[] {
      let currentDevice: Device = devices[0];

      devices.forEach((device: Device, index: number) => {
        if (device.current) {
          currentDevice = device;
          devices.splice(index, 1);
          devices.unshift(device);
        }
      });

      currentDevice.sessions.forEach((session: Session, index: number) => {
        if (session.current) {
          const currentSession: Session[] = currentDevice.sessions.splice(index, 1);
          currentDevice.sessions.unshift(currentSession[0]);
        }
      });

      return devices;
    }

    private time(time: number): string {
      return moment(time * 1000).format('LLLL');
    }

    private findBrowserIcon(session: Session): React.ReactNode {
      const browserName: string = session.browser.toLowerCase();
      if (browserName.includes("chrom")) return (<ChromeIcon size='lg'/>); // chrome or chromium
      if (browserName.includes("firefox")) return (<FirefoxIcon size='lg'/>);
      if (browserName.includes("edge")) return (<EdgeIcon size='lg'/>);
      if (browserName.startsWith("ie/")) return (<InternetExplorerIcon size='lg'/>);
      if (browserName.includes("safari")) return (<SafariIcon size='lg'/>);
      if (browserName.includes("opera")) return (<OperaIcon size='lg'/>);
      if (browserName.includes("yandex")) return (<YandexInternationalIcon size='lg'/>);
      if (browserName.includes("amazon")) return (<AmazonIcon size='lg'/>);

      return (<GlobeIcon size='lg'/>);
    }

    private findOS(device: Device): string {
      if (device.os.toLowerCase().includes('unknown')) return Msg.localize('unknownOperatingSystem');

      return device.os;
    }

    private findOSVersion(device: Device): string {
      if (device.osVersion.toLowerCase().includes('unknown')) return '';

      return device.osVersion;
    }

    private makeClientsString(clients: Client[]): string {
      let clientsString = "";
      clients.forEach( (client: Client, index: number) => {
        let clientName: string;
        if (client.hasOwnProperty('clientName') && (client.clientName !== undefined) && (client.clientName !== '')) {
          clientName = Msg.localize(client.clientName);
        } else {
          clientName = client.clientId;
        }

        clientsString += clientName;

        if (clients.length > index + 1) clientsString += ', ';
      })

      return clientsString;
    }

    private isShowSignOutAll(devices: Device[]): boolean {
      if (devices.length === 0) return false;
      if (devices.length > 1) return true;
      if (devices[0].sessions.length > 1) return true;

      return false;
    }

    public render(): React.ReactNode {
      
      return (
        <ContentPage title="device-activity" onRefresh={this.fetchDevices.bind(this)}>
          <Stack gutter="md">
            <StackItem isFilled>
              <DataList aria-label={Msg.localize('signedInDevices')}>
                  <DataListItem key="SignedInDevicesHeader" aria-labelledby="signedInDevicesTitle" isExpanded={false}>
                      <DataListItemRow>
                          <DataListItemCells
                              dataListCells={[
                                <DataListCell key='signedInDevicesTitle' width={4}>
                                  <div id="signedInDevicesTitle" className="pf-c-content">
                                      <h2><Msg msgKey="signedInDevices"/></h2>
                                      <p>
                                          <Msg msgKey="signedInDevicesExplanation"/>
                                      </p>
                                  </div>
                                </DataListCell>,
                                <DataListCell key='signOutAllButton' width={1}>
                                  {this.isShowSignOutAll(this.state.devices) && 
                                    <ContinueCancelModal buttonTitle='signOutAllDevices'
                                                  modalTitle='signOutAllDevices'
                                                  modalMessage='signOutAllDevicesWarning'
                                                  onContinue={this.signOutAll}
                                    />
                                  }
                                </DataListCell>
                              ]}
                          />
                      </DataListItemRow>
                  </DataListItem>
                  
                  <DataListItem aria-labelledby='sessions'>
                    <Grid gutter='sm'>
                    <GridItem span={12}/> {/* <-- top spacing */}
                      {this.state.devices.map((device: Device, deviceIndex: number) => {
                        return (
                          <React.Fragment>
                            {device.sessions.map((session: Session, sessionIndex: number) => {
                              return (
                                <React.Fragment key={'device-' + deviceIndex + '-session-' + sessionIndex}>
                                  
                                  <GridItem span={3}>
                                   <Stack>
                                      <StackItem isFilled={false}>
                                        <Bullseye>{this.findBrowserIcon(session)}</Bullseye>
                                      </StackItem>
                                      {!this.state.devices[0].mobile &&
                                        <StackItem isFilled={false}>
                                          <Bullseye>{session.ipAddress}</Bullseye>
                                        </StackItem>
                                      }
                                      {session.current && 
                                        <StackItem isFilled={false}>
                                          <Bullseye><strong className='pf-c-badge pf-m-read'><Msg msgKey="currentSession"/></strong></Bullseye>
                                        </StackItem>
                                      }
                                    </Stack>
                                  </GridItem>
                                  <GridItem span={9}>
                                    {!session.browser.toLowerCase().includes('unknown') &&
                                      <p><strong>{session.browser} / {this.findOS(device)} {this.findOSVersion(device)}</strong></p>
                                    }
                                    {this.state.devices[0].mobile &&
                                      <p><strong>{Msg.localize('ipAddress')} </strong> {session.ipAddress}</p>
                                    }
                                    <p><strong>{Msg.localize('lastAccessedOn')}</strong> {this.time(session.lastAccess)}</p>
                                    <p><strong>{Msg.localize('clients')}</strong> {this.makeClientsString(session.clients)}</p>
                                    <p><strong>{Msg.localize('startedAt')}</strong> {this.time(session.started)}</p>
                                    <p><strong>{Msg.localize('expiresAt')}</strong> {this.time(session.expires)}</p>
                                    {!session.current && 
                                      <ContinueCancelModal buttonTitle='doSignOut'
                                                          modalTitle='doSignOut'
                                                          buttonVariant='secondary'
                                                          modalMessage='signOutWarning'                                        
                                                          onContinue={() => this.signOutSession(device, session)}
                                      />
                                    } 
                                    
                                  </GridItem>
                                </React.Fragment>
                              );
                              
                            })}
                          </React.Fragment>
                        )
                      })}
                    <GridItem span={12}/> {/* <-- bottom spacing */}
                    </Grid>
                  </DataListItem>
              </DataList>
            </StackItem>
            
          </Stack>
        </ContentPage>
        );
    }
};