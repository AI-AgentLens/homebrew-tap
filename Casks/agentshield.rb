cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.788"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.788/agentshield_0.2.788_darwin_amd64.tar.gz"
      sha256 "d65accbf63a7374457ab9b702497ee20cf6e8cbe54538c8a01d4301732e560c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.788/agentshield_0.2.788_darwin_arm64.tar.gz"
      sha256 "ec0ddafaa12a9b2310a6985f9906319c2df5295824051ce6b6af362e6206842d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.788/agentshield_0.2.788_linux_amd64.tar.gz"
      sha256 "e36a19ef9a538956b3d4ce1d4ed1e3fddee804a16695177992e89a7986c9ab7e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.788/agentshield_0.2.788_linux_arm64.tar.gz"
      sha256 "70e0357a76b28fb7bdcf6c7b28c78ed8651aace466d8d673cad590c80186151e"
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
