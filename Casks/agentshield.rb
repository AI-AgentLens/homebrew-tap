cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.199"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.199/agentshield_0.2.199_darwin_amd64.tar.gz"
      sha256 "501287ed01c3bea8ed23f9fc7e4447439c07c1e70789dd86b317cd847a377f8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.199/agentshield_0.2.199_darwin_arm64.tar.gz"
      sha256 "a7e76287948b279b4bec9cf6429c0cee0fe4e2bccff33106ad68534d668c74e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.199/agentshield_0.2.199_linux_amd64.tar.gz"
      sha256 "3e60c5a225dee3d177504e9ced4b53c11971b3fb002f7ffb22fe7aa8e34f3f6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.199/agentshield_0.2.199_linux_arm64.tar.gz"
      sha256 "d1ce5452236f3d1106167061490c730c170d57c1c26895661f1955ed8f08d8a5"
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
