cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1639"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1639/agentshield_0.2.1639_darwin_amd64.tar.gz"
      sha256 "68bf4db144631dc2b670ec9e6400100a243a71a299f2002b52a8507e72dedbcc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1639/agentshield_0.2.1639_darwin_arm64.tar.gz"
      sha256 "8c81e679cbb6c768d7cfd34dabfee088bf4f3510abb21fb9d1ba1e92c9f3d75a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1639/agentshield_0.2.1639_linux_amd64.tar.gz"
      sha256 "eeffda5f51728f4f86c50aa42fdd5a81297225692ca6f77b981e8148e96ae419"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1639/agentshield_0.2.1639_linux_arm64.tar.gz"
      sha256 "9a7b0bee621c578870bcefaded6e6acce7ad8a3859deb938aa8f95647b589223"
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
