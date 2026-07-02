cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1528"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1528/agentshield_0.2.1528_darwin_amd64.tar.gz"
      sha256 "8ab3b01c55d3428f32e29caa7202b08848b0024b4483ee6c9e966e40e243484c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1528/agentshield_0.2.1528_darwin_arm64.tar.gz"
      sha256 "aac339f0b37875d75aa26c3b15104c02beb7884cbee2d76a73b75e0dc1213ba0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1528/agentshield_0.2.1528_linux_amd64.tar.gz"
      sha256 "a0427a4778e3fafbb2eb45ea60d95b8d6002169880ec55563fe1a94bb17627d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1528/agentshield_0.2.1528_linux_arm64.tar.gz"
      sha256 "f521605f03392a865b4732cb6190b4a60727454fe5936367556d10c23339560c"
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
