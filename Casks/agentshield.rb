cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2456"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2456/agentshield_0.2.2456_darwin_amd64.tar.gz"
      sha256 "e27d4cfd934c5157b4df1501e7a461e027cff921bd1b444cf6dd6644ecd5c7ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2456/agentshield_0.2.2456_darwin_arm64.tar.gz"
      sha256 "d9e3d02de6b512414d9a1ab6d97d692f26041c6fce4e373b9d92471098b7dde0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2456/agentshield_0.2.2456_linux_amd64.tar.gz"
      sha256 "8421f46110c571f60e526cdaeeeb975db117c7e81c8eb934da7669f7d69f188d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2456/agentshield_0.2.2456_linux_arm64.tar.gz"
      sha256 "ea8c4f11f69a346142194d1e830a208a8c463d5cc7c17807ef89b0f1edc831e3"
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
