cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2239"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2239/agentshield_0.2.2239_darwin_amd64.tar.gz"
      sha256 "142de289d7c67e7c2ca85552de83f0649e4ef033d23cd55033c3b865fa5c2bdb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2239/agentshield_0.2.2239_darwin_arm64.tar.gz"
      sha256 "7c5e00838c514fd36631d1652afd6a3b9d67592ce09bf95f9424b930e39aaa0c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2239/agentshield_0.2.2239_linux_amd64.tar.gz"
      sha256 "ef30a9308922192572345d1286c83e40cebd4708fe422cd4ed1ced1a0bbeae0f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2239/agentshield_0.2.2239_linux_arm64.tar.gz"
      sha256 "412fd0573c298ec7a959c8e4967edb5ba530c8076a3a964f72d8e6916f692022"
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
