cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.897"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.897/agentshield_0.2.897_darwin_amd64.tar.gz"
      sha256 "accfe4d403f7d3a1ad76422911ea1354dc40410e58fd1da3fbc727d84e581f78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.897/agentshield_0.2.897_darwin_arm64.tar.gz"
      sha256 "3022c9c5f1e4fece65851dd10efa98f113c0f8a8c011e5c14a94a67c2f0c8a4b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.897/agentshield_0.2.897_linux_amd64.tar.gz"
      sha256 "3f54407f4e29c1cd6ecd665df2eb3546994dc5b3ac08efdca2452b6ecc7ddb37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.897/agentshield_0.2.897_linux_arm64.tar.gz"
      sha256 "bb695cf39e26508a2d9a8e721f0e93c895c2cc85699114f29d48ba5b0db7eaf8"
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
