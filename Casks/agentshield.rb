cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.168"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.168/agentshield_0.2.168_darwin_amd64.tar.gz"
      sha256 "1ec38074e9ccd441d223cbcdce53ee39e42e918924034208b4f527850e0c8f0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.168/agentshield_0.2.168_darwin_arm64.tar.gz"
      sha256 "ae80316cc8760c7e4257ee5ca8de665b02f5b880e1d9e9be64ed3e8a5992d8db"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.168/agentshield_0.2.168_linux_amd64.tar.gz"
      sha256 "ac446921d9fa543be53564d868b83d2544bb1831ad3bd276a48878479cce166a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.168/agentshield_0.2.168_linux_arm64.tar.gz"
      sha256 "8ffb95343756c4bd23ca87f3280dfdfe9f27988060f55ce6c1b52f1344a145e1"
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
