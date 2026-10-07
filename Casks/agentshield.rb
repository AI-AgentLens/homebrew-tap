cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2373"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2373/agentshield_0.2.2373_darwin_amd64.tar.gz"
      sha256 "25018a24460b2e9866ae67ae39e00c0bb844ce6b9bc65414578e1626fa13852f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2373/agentshield_0.2.2373_darwin_arm64.tar.gz"
      sha256 "7c86ba944f5ba247164754629d40c65d4a2ca71b9f83ec51995270e313792796"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2373/agentshield_0.2.2373_linux_amd64.tar.gz"
      sha256 "07ce95df3766ca699eec97b1f81f21c4d3892bd84ebde9543c6e23fa53dd51b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2373/agentshield_0.2.2373_linux_arm64.tar.gz"
      sha256 "9c453ecc989cadf89953b9f27631b32f2748cb85816d2d103a4b19e16fea656e"
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
