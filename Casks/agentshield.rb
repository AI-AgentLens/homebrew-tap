cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.879"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.879/agentshield_0.2.879_darwin_amd64.tar.gz"
      sha256 "a35e883220d1f4816bccc1d203e046084a5d633aa9b36d5fdb8f1360365446bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.879/agentshield_0.2.879_darwin_arm64.tar.gz"
      sha256 "9b1e55c1328fe25d10046c9182870b6722adea34936de4b0745daa98fe655887"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.879/agentshield_0.2.879_linux_amd64.tar.gz"
      sha256 "987af0b72802db92ac63bf042e3c383e6c9f535172436a1ffbd0671583406a53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.879/agentshield_0.2.879_linux_arm64.tar.gz"
      sha256 "d2e20b2e9ef8d1eb51cee8638c257e87d88bbb437935acb77aff1ed00d17d9f0"
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
