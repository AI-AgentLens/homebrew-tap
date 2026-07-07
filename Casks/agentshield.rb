cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1581"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1581/agentshield_0.2.1581_darwin_amd64.tar.gz"
      sha256 "00e253b100150f066fa754254f360b8beee9189efbca60e1f8349e6a5869302a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1581/agentshield_0.2.1581_darwin_arm64.tar.gz"
      sha256 "910dadc94719d3c8dae6a4efe3c4fa47ea15e8601253ca584394b80f852e2757"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1581/agentshield_0.2.1581_linux_amd64.tar.gz"
      sha256 "37331964fd08637b01f1e1203712b2a73884395b1d0b84bb91bd47e9ddc2f2f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1581/agentshield_0.2.1581_linux_arm64.tar.gz"
      sha256 "1664e4dc9883da84a96f14f4c76e8ea589bc0065a3802f4283afb5e87438251e"
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
