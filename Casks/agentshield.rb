cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1709"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1709/agentshield_0.2.1709_darwin_amd64.tar.gz"
      sha256 "88e16cdae823c361dd57ce67b10c02ec5651b91af3939ebaf8b54b09b6c99139"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1709/agentshield_0.2.1709_darwin_arm64.tar.gz"
      sha256 "dd935ab5da84a4364c092142c043f6badcef089f56a4a8d0ef651d3f0d500a85"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1709/agentshield_0.2.1709_linux_amd64.tar.gz"
      sha256 "98ed24550959999c305c449c6a7a42917dfac2a7993619bb4259eb962eac8cc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1709/agentshield_0.2.1709_linux_arm64.tar.gz"
      sha256 "367c1c3406f356ff1e182a8bcbecdd390dde8b962c5ba77095ecd12b8a9f34f0"
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
