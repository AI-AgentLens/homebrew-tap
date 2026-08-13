cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1842"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1842/agentshield_0.2.1842_darwin_amd64.tar.gz"
      sha256 "d3cc85ee327b3a38f3f14e2f21c032f916d5262c8bde5bcba3a0e2b8aa9b5ce0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1842/agentshield_0.2.1842_darwin_arm64.tar.gz"
      sha256 "5c609c7b9cd92b82bdc9f8916b86bcb81f78da0a915de57b7370f482b31c2b33"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1842/agentshield_0.2.1842_linux_amd64.tar.gz"
      sha256 "152c38fbacc9c871f8f687448373ca9b45dcac3cdc26df4dfaf4f54f4c5fe5ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1842/agentshield_0.2.1842_linux_arm64.tar.gz"
      sha256 "9b071f4d0ccf4191a806fc10f9efa64993db09fd217b597399a4db29ed4690ac"
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
