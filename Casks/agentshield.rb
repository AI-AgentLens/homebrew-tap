cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1022"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1022/agentshield_0.2.1022_darwin_amd64.tar.gz"
      sha256 "b24318fb20dacb305bfb54d6d468a9e422f7ec67cad0e58d45a1afcb4c104d72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1022/agentshield_0.2.1022_darwin_arm64.tar.gz"
      sha256 "4152443bdbbf5ee1f74e10c51ed52989fe049a19e9fac0f302f3a16efd5688d6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1022/agentshield_0.2.1022_linux_amd64.tar.gz"
      sha256 "0a7e3c36624434284660697f11b7248c4a89cbf7962810951431fe9e6afc273c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1022/agentshield_0.2.1022_linux_arm64.tar.gz"
      sha256 "5391ccdeed24274d0263bae5dbbc79d52101528058ab6075ea566909cdd74d21"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
