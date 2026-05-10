cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.937"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.937/agentshield_0.2.937_darwin_amd64.tar.gz"
      sha256 "a2818ac04f4f10091fbe0802020dbd405c1f0e2a7c42484d60eed196fc4f61af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.937/agentshield_0.2.937_darwin_arm64.tar.gz"
      sha256 "66c9c889fab3dbb7660167b8a414ea5745428b1302993119091f144629c6af3a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.937/agentshield_0.2.937_linux_amd64.tar.gz"
      sha256 "570f9517da303209479a40d6a7c3dd2482d406c08a600890002af8ed3a27ef76"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.937/agentshield_0.2.937_linux_arm64.tar.gz"
      sha256 "b91491f0522f5629d8e4cf8e5ff2406e27832e81b22624716f34276bb5f38e92"
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
