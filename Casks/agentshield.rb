cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2493"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2493/agentshield_0.2.2493_darwin_amd64.tar.gz"
      sha256 "d00bb0ac229ed1f86b4b192b25afe0d519679bef0daf357092cc2924f64467c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2493/agentshield_0.2.2493_darwin_arm64.tar.gz"
      sha256 "461cd9700d5ea0c2db1989a77fc5454f9cd6152b30c9d606994276d922c1592b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2493/agentshield_0.2.2493_linux_amd64.tar.gz"
      sha256 "b474f368bffc6e539a2f4632a7a5494a3769cb27814bd4ec851157e441d4f14e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2493/agentshield_0.2.2493_linux_arm64.tar.gz"
      sha256 "149721e168e671432c09ae525020aac0695163b707331c50153b4a5b899ea21c"
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
